Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AE4F6B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 03:28:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id i77so11724454wmh.10
        for <linux-mm@kvack.org>; Mon, 29 May 2017 00:28:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t20si9542434edi.172.2017.05.29.00.28.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 May 2017 00:28:33 -0700 (PDT)
Date: Mon, 29 May 2017 09:28:31 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH v2] mm: fix mlock incorrent event account
Message-ID: <20170529072830.GB19725@dhcp22.suse.cz>
References: <1495770854-13920-1-git-send-email-zhongjiang@huawei.com>
 <e30ea010-1cee-a1d9-9136-249372ea1640@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e30ea010-1cee-a1d9-9136-249372ea1640@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: zhongjiang <zhongjiang@huawei.com>, akpm@linux-foundation.org, qiuxishi@huawei.com, linux-mm@kvack.org

On Fri 26-05-17 11:06:31, Vlastimil Babka wrote:
> On 05/26/2017 05:54 AM, zhongjiang wrote:
> > From: zhong jiang <zhongjiang@huawei.com>
> > 
> > Recently, when I address in the issue, Subject "mlock: fix mlock count
> > can not decrease in race condition" had been take over, I review
> > the code and find the potential issue. it will result in the incorrect
> > account, it will make us misunderstand straightforward.
> > 
> > The following testcase can prove the issue.
> > 
> > int main(void)
> > {
> >     char *map;
> >     int fd;
> > 
> >     fd = open("test", O_CREAT|O_RDWR);
> >     unlink("test");
> >     ftruncate(fd, 4096);
> >     map = mmap(NULL, 4096, PROT_WRITE, MAP_PRIVATE, fd, 0);
> >     map[0] = 11;
> >     mlock(map, 4096);
> >     ftruncate(fd, 0);
> >     close(fd);
> >     munlock(map, 4096);
> >     munmap(map, 4096);
> > 
> >     return 0;
> > }
> > 
> > before:
> > unevictable_pgs_mlocked 10589
> > unevictable_pgs_munlocked 10588
> > unevictable_pgs_cleared 1
> > 
> > apply the patch;
> > after:
> > unevictable_pgs_mlocked 9497
> > unevictable_pgs_munlocked 9497
> > unevictable_pgs_cleared 1
> > 
> > unmap_mapping_range unmap them,  page_remove_rmap will deal with
> > clear_page_mlock situation.  we clear page Mlock flag and successful
> > isolate the page,  the page will putback the evictable list. but it is not
> > record the munlock event.
> > 
> > The patch add the event account when successful page isolation.
> > 
> > Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> 
> Hi,
> 
> I think this is by design. UNEVICTABLE_PGMUNLOCKED is supposed for explicit
> munlock() actions from userspace. Truncation etc is counted by
> UNEVICTABLE_PGCLEARED.

I guess we really need to change
$ git grep UNEVICTABLE_PGCLEARED -- Documentation/
$

into something more comprehensive
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
