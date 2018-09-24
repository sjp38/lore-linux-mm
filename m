Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91D938E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 19:48:58 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id z17-v6so24195297qka.9
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 16:48:58 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0074.outbound.protection.outlook.com. [104.47.33.74])
        by mx.google.com with ESMTPS id j128-v6si549806qke.154.2018.09.24.16.48.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Sep 2018 16:48:57 -0700 (PDT)
Date: Tue, 25 Sep 2018 02:48:43 +0300
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH] mm: fix COW faults after mlock()
Message-ID: <20180924234843.GA23726@yury-thinkpad>
References: <20180924130852.12996-1-ynorov@caviumnetworks.com>
 <20180924212246.vmmsmgd5qw6xkfwh@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924212246.vmmsmgd5qw6xkfwh@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Dan Williams <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>, "Michael S . Tsirkin" <mst@redhat.com>, Michel Lespinasse <walken@google.com>, Souptick Joarder <jrdr.linux@gmail.com>, Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 25, 2018 at 12:22:47AM +0300, Kirill A. Shutemov wrote:
> External Email
> 
> On Mon, Sep 24, 2018 at 04:08:52PM +0300, Yury Norov wrote:
> > After mlock() on newly mmap()ed shared memory I observe page faults.
> >
> > The problem is that populate_vma_page_range() doesn't set FOLL_WRITE
> > flag for writable shared memory in mlock() path, arguing that like:
> > /*
> >  * We want to touch writable mappings with a write fault in order
> >  * to break COW, except for shared mappings because these don't COW
> >  * and we would not want to dirty them for nothing.
> >  */
> >
> > But they are actually COWed. The most straightforward way to avoid it
> > is to set FOLL_WRITE flag for shared mappings as well as for private ones.
> 
> Huh? How do shared mapping get CoWed?
> 
> In this context CoW means to create a private copy of the  page for the
> process. It only makes sense for private mappings as all pages in shared
> mappings do not belong to the process.
> 
> Shared mappings will still get faults, but a bit later -- after the page
> is written back to disc, the page get clear and write protected to catch
> the next write access.
> 
> Noticeable exception is tmpfs/shmem. These pages do not belong to normal
> write back process. But the code path is used for other filesystems as
> well.
> 
> Therefore, NAK. You only create unneeded write back traffic.

Hi Kirill,

(My first reaction was exactly like yours indeed, but) on my real
system (Cavium OcteonTX2), and on my qemu simulation I can reproduce
the same behavior: just mlock()ed memory causes faults. That faults
happen because page is mapped to the process as read-only, while
underlying VMA is read-write. So faults get resolved well by just
setting write access to the page.

Maybe I use term COW wrongly here, but this is how faultin_page()
works, and it sets FOLL_COW bit before return (which is ignored 
on upper level).

I realize that proper fix may be more complex, and if so I'll
thankfully take it and drop this patch from my tree, but this is
all that I have so far to address the problem.

The user code below is reproducer. 

Thanks,
Yury

        int i, ret, len = getpagesize() * 1000;
        char tmpfile[] = "/tmp/my_tmp-XXXXXX";
        int fd = mkstemp(tmpfile);

        ret = ftruncate(fd, len);
        if (ret) {
                printf("Failed to ftruncate: %d\n", errno);
                goto out;
        }

        ptr = mmap(NULL, len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        if (ptr == MAP_FAILED) {
                printf("Failed to mmap memory: %d\n", errno);
                goto out;
        }

        ret = mlock(ptr, len);
        if (ret) {
                printf("Failed to mlock: %d\n", errno);
                goto out;
        }

        printf("Touch...\n");

        for (i = 0; i < len; i++)
                ptr[i] = (char) i; /* Faults here. */

        printf("\t... done\n");
out:
        close(fd);
        unlink(tmpfile);
