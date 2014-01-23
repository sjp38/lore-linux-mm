Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id C1D746B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 08:19:57 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id r7so350299bkg.33
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 05:19:57 -0800 (PST)
Received: from mail-pb0-x242.google.com (mail-pb0-x242.google.com [2607:f8b0:400e:c01::242])
        by mx.google.com with ESMTPS id rl5si10235790bkb.165.2014.01.23.05.19.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 05:19:56 -0800 (PST)
Received: by mail-pb0-f66.google.com with SMTP id md12so1057816pbc.1
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 05:19:54 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 23 Jan 2014 21:19:54 +0800
Message-ID: <CABDjeFeXqJPAKFFz9vG1pgqEjNJpW3ciLH3LfGCjPYrAcL6xRQ@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] Fadvise Extensions for Directory Level Cache
 Cleaning and POSIX_FADV_NOREUSE
From: Qing Wei <weiqing369@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b2e3f34dd9da104f0a3183b
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <dragonylffly@163.com>
Cc: lsf-pc <lsf-pc@lists.linux-foundation.org>, "inux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>

--047d7b2e3f34dd9da104f0a3183b
Content-Type: text/plain; charset=UTF-8

Hi,

On 01/20/2014 10:56 PM, Li Wang wrote:

>
> Hello,
>   It will be appreciated if I have a chance to discuss the fadvise
> extension topic at the incoming LSF/MM summit. I am also very
> interested in the topics on VFS, MM, SSD optimization as well as ext4,
> xfs, ceph and so on.
>  In the last year, I have been involved in Ceph development, the
> features done/ongoing include punch hole support, inline data
> support, cephfs quota support, cephfs fuse file lock support etc, as
> well as some bug fixes and performance evaluations.
>
> The proposal is below, comments/suggestions are welcome.
>
> Fadvise Extensions for Directory Level Cache Cleaning and
> POSIX_FADV_NOREUSE
>
> 1 Motivation
>
> 1.1 Directory Level Cache Cleaning
>
> VFS relies on LRU-like page cache eviction algorithm to reclaim cache
> space, since LRU is not aware of application semantics, it may
> incorrectly evict going-to-be referenced pages out, resulting in severe
> performance degradation due to cache thrashing, especially under high
> memory pressure situation. Applications have the most semantic
> knowledge, they can always do better if they are given a chance. This
> motivates to endow the applications more abilities to manipulate the
> vfs cache.
>
> Currently, Linux support file system wide cache cleaning by virtue of
> proc interface 'drop-caches', but it is very coarse granularity and
> was originally proposed for debugging. The other is to do file-level
> page cache cleaning through 'fadvise', however, since there is no way of
> determining whether a path name is in the dentry cache, simply calling
> fadvise(name, DONTNEED) will very likely pollute the cache rather
> than cleaning it. Even there is a cache query API available, it will
> incur heavy system call overhead, especially in massive small-file
> situations. This motivates to extend fadvise() to support directory
> level cache cleaning. Currently, the original implementation is
> available at https://lkml.org/lkml/2013/12/30/147, and received some
> constructive comments. We think there are some designs need be put
> under discussion, and we summarize them in Section 2.1.
>
> 1.2 POSIX_FADV_NOREUSE
>
> POSIX_FADV_NOREUSE is useful for backup and data streaming applications.
> There are already some efforts on POSIX_FADV_NOREUSE implementation,
> the latest seems to be https://lkml.org/lkml/2012/2/11/133. The
> alternative ways can be (a) Use fadvise(DONTNEED) instead; (b) Use
> container-based approach, such as setting memory.file.limit_in_bytes.
> However, both (a) and (b) have limitations. (a) may impolitely destroy
> other application's work set, which is not a desirable behavior; (b) is
> kind of rude, and the threshold may have to be  carefully tuned,
> otherwise it may cause applications to start swapping  or even worse.
> In addition, we are not sure if it shares the same issue  with (a).
> This motivates to develop a simple yet efficient POSIX_FADV_NOREUSE
> implementation.
>
> 2 Designs to be discussed
>
> Since these are both suggestive interfaces, the overall idea behind our
> design is to minimize the modification to current MM magic, stay the
> implementation as simple as possible.
>
> 2.1 Directory Level Cache Cleaning
>
> For directory level cache cleaning, fadivse(fd, DONTNEED) will clean
> all the page caches as well as unreferenced dentry caches and inode
> caches inside the directory fd.
>
> (1) For page cache cleaning, the policy in our original design is to
> collect those inodes not on any LRU list into our private list for
> further cleaning. However, as pointed out by Andrew and Dave, most
> inodes are actually on the LRU list, hence this policy will leave many
> inodes fail to be processed. And, since we want to reuse the
> inode->i_lru rather than adding a new list_head field into inode, we
> will encounter a problem that we can not determine whether an inode is
> on superblock LRU list or on our private list. While a fadvise() caller
> A is trying to collect an inode, it may happen that another fadvise()
> caller B has already gathered the inode into his private LRU list, then
> it will end up that A grabs inode from B's list, and the worse thing is,
> the operations on B'list are not synchronized within multiple fadvise()
> callers. To address this, We have two candidates,
>
> (a) Introduce a new inode state I_PRIVATE, indicating the inode is on a
> private list. While collecting one inode into private list, the flag is
> set on it, and cleared after finishing page cache invalidation.
> Fadvise() caller will check the flag prior to collecting one inode into
> his private list. This avoids the race between one fadvise() caller is
> adding a new inode to his list and another caller is grabbing a inode
> from this list.
>
> (b) Introduce a global list as well as a global lock. The inodes to be
> manipulated are always collected into the global list, protected by the
> global lock. Given the cache cleaning is not a frequent operation, the
> performance impact is negligible.
>
> (2) For dentry cache cleaning, shrink_dcache_parent() meets most of our
> demands except it does not take permission into account, the caller
> should not touch the dentries and inodes which he does not own
> appropriate permission. There are also two ways to perform the check,
>
> (a) Check if the caller has permission on parent directory, i.e,
> inode_permission(dentry->d_parent->d_inode, MAY_WRITE | MAY_EXEC)
>
> (b) Check if the caller has permission on corresponding inode, i.e,
> (inode_owner_or_capable(dentry->d_inode) || capable(CAP_SYS_ADMIN))
>
> (3) For dentry cache cleaning, if dentries are freed, there seems no
> easy way to walk all inodes inside a specific directory, our idea lies
> in that before freeing those unreferenced dentries, gather the inodes
> referenced by them into a private list, __iget() the inodes and mark
> I_PRIVATE on (if the I_PRIVATE scheme is acceptable). Thereafter from
> where we can still find those inodes to further free them.
>
> (4) For inode cache cleaning, in most situations, iput_final() will put
> unreferenced inodes into superblock lru list rather than freeing them.
> To free the inodes in our private list, it seems there is not a handy
> API to use. The process could be, for each inode in our list, hold the
> inode lock, clear I_PRIVATE, detach from list, atomic decrease its
> reference count. If the reference count reaches zero, there are two
> possible ways,
>
> (a) Introduce a new inode state I_FORCE_FREE, and mark it on, then pass
> the inode into iput_final(). iput_final() is with tiny modifications to
> be able to recognize the flag, who will then invoke evict() to free the
> inode rather than adding it to super block LRU list.
>
> (b) Wrap iput_final() into __iput_final(struct inode *inode, bool
> force_free), we call __iput_final(inode, TRUE), define iput_final() to
> static inline __iput_final(inode, FALSE).
>
> 2.2 POSIX_FADV_NOREUSE Implementation
>
> Our key idea behind is to translate 'The application will access the
> page once' into 'The access leaves no side-effect on the page'. For
> current MM implementation, normal access will has side-effect on the
> page accessed, i.e, it will increase the temperature of the page,
> in a way of from inactive to active or from unreferenced to referenced.
> Against normal access, NOREUSE is intended to tell the MM system that
> the access will leave the page as it is. This can be detailed as
> follows,
>
> (a) If a page is accessed for the first time, after NOREUSE access, it
> is kept inactive and unreferenced, then it will potentially get
> reclaimed soon since it has a lowest temperature, unless a later
> NON-NOREUSE access increases its temperature. Here we do not
> explicitly immediately free the page after access, this is for three
> reasons, the first is the semantics of NOREUSE differs from DONTNEED,
>  NOREUSE does not mean the page should be dropped  immediately; the
> second is synchronously freeing the page will more or less slow down
> the read performance; And the last, a near-future reference of the page
> by other applications will have a chance to hit in the cache.
>
> (b) If a page is accessed before, in other words, it is active or
> referenced, then it may belong to the work set of other applications,
> and will very likely be accessed again. NOREUSE just makes a silent
> access, without changing any status of the page.
>
> Another assumption is that file wide NOREUSE is enough to capture most
>  of the usages, the fine granularity of interval-level NOREUSE is not
> desirable given its rare use and its implementation complexity. So this
> results in the following simple NOREUSE implementation,
>
> (1) Introduce a new fmode FMODE_NOREUSE, set it on when calling
> fadvise(NOREUSE)
>
> So when will this flag be cleared? Do you need clear it while setting
FMODE_RANDOM, FMODE_NORMAL, FMODE_SEQ etc, like
https://lkml.org/lkml/2012/2/11/13 <https://lkml.org/lkml/2012/2/11/133>does?

(2) do_generic_file_read():
> From:
> if (prev_index != index || offset != prev_offset)
>     mark_page_accessed(page);
> To:
> if ((prev_index != index || offset != prev_offset) && !(filp->f_mode &
> FMODE_NOREUSE))
>     mark_page_accessed(page);
>     There are no more than ten LOC to go.
>
> Cheers,
> Li Wang
>
>
>
>
>
>

--047d7b2e3f34dd9da104f0a3183b
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi,<br><div><div></div><div class=3D"gmail_extra"><br><div=
 class=3D"gmail_quote">On 01/20/2014 10:56 PM, Li Wang wrote:<br><blockquot=
e class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px s=
olid rgb(204,204,204);padding-left:1ex">
<div dir=3D"ltr"><br><div class=3D"gmail_quote">
Hello,<br>
=C2=A0 It will be appreciated if I have a chance to discuss the fadvise<br>
extension topic at the incoming LSF/MM summit. I am also very<br>
interested in the topics on VFS, MM, SSD optimization as well as ext4,<br>
xfs, ceph and so on.<br>
=C2=A0In the last year, I have been involved in Ceph development, the<br>
features done/ongoing include punch hole support, inline data<br>
support, cephfs quota support, cephfs fuse file lock support etc, as<br>
well as some bug fixes and performance evaluations.<br>
<br>
The proposal is below, comments/suggestions are welcome.<br>
<br>
Fadvise Extensions for Directory Level Cache Cleaning and<br>
POSIX_FADV_NOREUSE<br>
<br>
1 Motivation<br>
<br>
1.1 Directory Level Cache Cleaning<br>
<br>
VFS relies on LRU-like page cache eviction algorithm to reclaim cache<br>
space, since LRU is not aware of application semantics, it may<br>
incorrectly evict going-to-be referenced pages out, resulting in severe<br>
performance degradation due to cache thrashing, especially under high<br>
memory pressure situation. Applications have the most semantic<br>
knowledge, they can always do better if they are given a chance. This<br>
motivates to endow the applications more abilities to manipulate the<br>
vfs cache.<br>
<br>
Currently, Linux support file system wide cache cleaning by virtue of<br>
proc interface &#39;drop-caches&#39;, but it is very coarse granularity and=
<br>
was originally proposed for debugging. The other is to do file-level<br>
page cache cleaning through &#39;fadvise&#39;, however, since there is no w=
ay of<br>
determining whether a path name is in the dentry cache, simply calling<br>
fadvise(name, DONTNEED) will very likely pollute the cache rather<br>
than cleaning it. Even there is a cache query API available, it will<br>
incur heavy system call overhead, especially in massive small-file<br>
situations. This motivates to extend fadvise() to support directory<br>
level cache cleaning. Currently, the original implementation is<br>
available at <a href=3D"https://lkml.org/lkml/2013/12/30/147" target=3D"_bl=
ank">https://lkml.org/lkml/2013/12/<u></u>30/147</a>, and received some<br>
constructive comments. We think there are some designs need be put<br>
under discussion, and we summarize them in Section 2.1.<br>
<br>
1.2 POSIX_FADV_NOREUSE<br>
<br>
POSIX_FADV_NOREUSE is useful for backup and data streaming applications.<br=
>
There are already some efforts on POSIX_FADV_NOREUSE implementation,<br>
the latest seems to be <a href=3D"https://lkml.org/lkml/2012/2/11/133" targ=
et=3D"_blank">https://lkml.org/lkml/2012/2/<u></u>11/133</a>. The<br>
alternative ways can be (a) Use fadvise(DONTNEED) instead; (b) Use<br>
container-based approach, such as setting memory.file.limit_in_bytes.<br>
However, both (a) and (b) have limitations. (a) may impolitely destroy<br>
other application&#39;s work set, which is not a desirable behavior; (b) is=
<br>
kind of rude, and the threshold may have to be =C2=A0carefully tuned,<br>
otherwise it may cause applications to start swapping =C2=A0or even worse.<=
br>
In addition, we are not sure if it shares the same issue =C2=A0with (a).<br=
>
This motivates to develop a simple yet efficient POSIX_FADV_NOREUSE<br>
implementation.<br>
<br>
2 Designs to be discussed<br>
<br>
Since these are both suggestive interfaces, the overall idea behind our<br>
design is to minimize the modification to current MM magic, stay the<br>
implementation as simple as possible.<br>
<br>
2.1 Directory Level Cache Cleaning<br>
<br>
For directory level cache cleaning, fadivse(fd, DONTNEED) will clean<br>
all the page caches as well as unreferenced dentry caches and inode<br>
caches inside the directory fd.<br>
<br>
(1) For page cache cleaning, the policy in our original design is to<br>
collect those inodes not on any LRU list into our private list for<br>
further cleaning. However, as pointed out by Andrew and Dave, most<br>
inodes are actually on the LRU list, hence this policy will leave many<br>
inodes fail to be processed. And, since we want to reuse the<br>
inode-&gt;i_lru rather than adding a new list_head field into inode, we<br>
will encounter a problem that we can not determine whether an inode is<br>
on superblock LRU list or on our private list. While a fadvise() caller<br>
A is trying to collect an inode, it may happen that another fadvise()<br>
caller B has already gathered the inode into his private LRU list, then<br>
it will end up that A grabs inode from B&#39;s list, and the worse thing is=
,<br>
the operations on B&#39;list are not synchronized within multiple fadvise()=
<br>
callers. To address this, We have two candidates,<br>
<br>
(a) Introduce a new inode state I_PRIVATE, indicating the inode is on a<br>
private list. While collecting one inode into private list, the flag is<br>
set on it, and cleared after finishing page cache invalidation.<br>
Fadvise() caller will check the flag prior to collecting one inode into<br>
his private list. This avoids the race between one fadvise() caller is<br>
adding a new inode to his list and another caller is grabbing a inode<br>
from this list.<br>
<br>
(b) Introduce a global list as well as a global lock. The inodes to be<br>
manipulated are always collected into the global list, protected by the<br>
global lock. Given the cache cleaning is not a frequent operation, the<br>
performance impact is negligible.<br>
<br>
(2) For dentry cache cleaning, shrink_dcache_parent() meets most of our<br>
demands except it does not take permission into account, the caller<br>
should not touch the dentries and inodes which he does not own<br>
appropriate permission. There are also two ways to perform the check,<br>
<br>
(a) Check if the caller has permission on parent directory, i.e,<br>
inode_permission(dentry-&gt;d_<u></u>parent-&gt;d_inode, MAY_WRITE | MAY_EX=
EC)<br>
<br>
(b) Check if the caller has permission on corresponding inode, i.e,<br>
(inode_owner_or_capable(<u></u>dentry-&gt;d_inode) || capable(CAP_SYS_ADMIN=
))<br>
<br>
(3) For dentry cache cleaning, if dentries are freed, there seems no<br>
easy way to walk all inodes inside a specific directory, our idea lies<br>
in that before freeing those unreferenced dentries, gather the inodes<br>
referenced by them into a private list, __iget() the inodes and mark<br>
I_PRIVATE on (if the I_PRIVATE scheme is acceptable). Thereafter from<br>
where we can still find those inodes to further free them.<br>
<br>
(4) For inode cache cleaning, in most situations, iput_final() will put<br>
unreferenced inodes into superblock lru list rather than freeing them.<br>
To free the inodes in our private list, it seems there is not a handy<br>
API to use. The process could be, for each inode in our list, hold the<br>
inode lock, clear I_PRIVATE, detach from list, atomic decrease its<br>
reference count. If the reference count reaches zero, there are two<br>
possible ways,<br>
<br>
(a) Introduce a new inode state I_FORCE_FREE, and mark it on, then pass<br>
the inode into iput_final(). iput_final() is with tiny modifications to<br>
be able to recognize the flag, who will then invoke evict() to free the<br>
inode rather than adding it to super block LRU list.<br>
<br>
(b) Wrap iput_final() into __iput_final(struct inode *inode, bool<br>
force_free), we call __iput_final(inode, TRUE), define iput_final() to<br>
static inline __iput_final(inode, FALSE).<br>
<br>
2.2 POSIX_FADV_NOREUSE Implementation<br>
<br>
Our key idea behind is to translate &#39;The application will access the<br=
>
page once&#39; into &#39;The access leaves no side-effect on the page&#39;.=
 For<br>
current MM implementation, normal access will has side-effect on the<br>
page accessed, i.e, it will increase the temperature of the page,<br>
in a way of from inactive to active or from unreferenced to referenced.<br>
Against normal access, NOREUSE is intended to tell the MM system that<br>
the access will leave the page as it is. This can be detailed as<br>
follows,<br>
<br>
(a) If a page is accessed for the first time, after NOREUSE access, it<br>
is kept inactive and unreferenced, then it will potentially get<br>
reclaimed soon since it has a lowest temperature, unless a later<br>
NON-NOREUSE access increases its temperature. Here we do not<br>
explicitly immediately free the page after access, this is for three<br>
reasons, the first is the semantics of NOREUSE differs from DONTNEED,<br>
=C2=A0NOREUSE does not mean the page should be dropped =C2=A0immediately; t=
he<br>
second is synchronously freeing the page will more or less slow down<br>
the read performance; And the last, a near-future reference of the page<br>
by other applications will have a chance to hit in the cache.<br>
<br>
(b) If a page is accessed before, in other words, it is active or<br>
referenced, then it may belong to the work set of other applications,<br>
and will very likely be accessed again. NOREUSE just makes a silent<br>
access, without changing any status of the page.<br>
<br>
Another assumption is that file wide NOREUSE is enough to capture most<br>
=C2=A0of the usages, the fine granularity of interval-level NOREUSE is not<=
br>
desirable given its rare use and its implementation complexity. So this<br>
results in the following simple NOREUSE implementation,<br>
<br>
(1) Introduce a new fmode FMODE_NOREUSE, set it on when calling<br>
fadvise(NOREUSE)<br>
<br></div></div></blockquote><div>So when will this flag be cleared? Do you=
 need clear it while setting <br>FMODE_RANDOM, FMODE_NORMAL, FMODE_SEQ etc,=
 like <br><a href=3D"https://lkml.org/lkml/2012/2/11/133" target=3D"_blank"=
>https://lkml.org/lkml/2012/2/11/13</a> does?<br>
<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8=
ex;border-left:1px solid rgb(204,204,204);padding-left:1ex"><div dir=3D"ltr=
"><div class=3D"gmail_quote">
(2) do_generic_file_read():<br>
From:<br>
if (prev_index !=3D index || offset !=3D prev_offset)<br>
=C2=A0 =C2=A0 mark_page_accessed(page);<br>
To:<br>
if ((prev_index !=3D index || offset !=3D prev_offset) &amp;&amp; !(filp-&g=
t;f_mode &amp;<br>
FMODE_NOREUSE))<br>
=C2=A0 =C2=A0 mark_page_accessed(page);<br>
=C2=A0 =C2=A0 There are no more than ten LOC to go.<br>
<br>
Cheers,<br>
Li Wang<br>
<br>
<br>
<br>
<br>
</div><br><div></div></div>
</blockquote></div><br></div></div></div>

--047d7b2e3f34dd9da104f0a3183b--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
