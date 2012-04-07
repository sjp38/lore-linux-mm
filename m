Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 5FE516B004D
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 20:18:44 -0400 (EDT)
Received: by lagz14 with SMTP id z14so3361863lag.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2012 17:18:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120217092205.GA9462@gmail.com>
References: <20120217092205.GA9462@gmail.com>
Date: Fri, 6 Apr 2012 17:18:42 -0700
Message-ID: <CALWz4iwSCWYsTdu2ur615Vrf9fSpp-c=ROGnWpuasFPSkNMDSQ@mail.gmail.com>
Subject: Re: Fine granularity page reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: linux-mm@kvack.org

On Fri, Feb 17, 2012 at 1:22 AM, Zheng Liu <gnehzuil.liu@gmail.com> wrote:
> Hi all,
>
> Currently, we encounter a problem about page reclaim. In our product syst=
em,
> there is a lot of applictions that manipulate a number of files. In these
> files, they can be divided into two categories. One is index file, anothe=
r is
> block file. The number of index files is about 15,000, and the number of
> block files is about 23,000 in a 2TB disk. The application accesses index
> file using mmap(2), and read/write block file using pread(2)/pwrite(2). W=
e hope
> to hold index file in memory as much as possible, and it works well in Re=
dhat
> 2.6.18-164. It is about 60-70% of index files that can be hold in memory.
> However, it doesn't work well in Redhat 2.6.32-133. I know in 2.6.18 that=
 the
> linux uses an active list and an inactive list to handle page reclaim, an=
d in
> 2.6.32 that they are divided into anonymous list and file list. So I am
> curious about why most of index files can be hold in 2.6.18?

One of changes after the split-lru is different scan ratio (active vs
inactive) for file-lru and anon-lru. You can check the following two
functions:

inactive_anon_is_low_global()
inactive_file_is_low_global()

Depends on your machine size, we might end of scanning more pages on file l=
ru.

--Ying

The index file
> should be replaced because mmap doesn't impact the lru list.
>
> BTW, I have some problems that need to be discussed.
>
> 1. I want to let index and block files are separately reclaimed. Is there=
 any
> ways to satisify me in current upstream?
>
> 2. Maybe we can provide a mechansim to let different files to be mapped i=
nto
> differnet nodes. we can provide a ioctl(2) to tell kernel that this file =
should
> be mapped into a specific node id. A nid member is added into addpress_sp=
ace
> struct. When alloc_page is called, the page can be allocated from that sp=
ecific
> node id.
>
> 3. Currently the page can be reclaimed according to pid in memcg. But it =
is too
> coarse. I don't know whether memcg could provide a fine granularity page
> reclaim mechansim. For example, the page is reclaimed according to inode =
number.
>
> I don't subscribe this mailing list, So please Cc me. Thank you.
>
> Regards,
> Zheng
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
