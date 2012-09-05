Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id B80C36B0068
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 16:41:34 -0400 (EDT)
Date: Wed, 5 Sep 2012 13:41:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix mmap overflow checking
Message-Id: <20120905134133.f5858d3c.akpm@linux-foundation.org>
In-Reply-To: <5046C4E7.5040407@cn.fujitsu.com>
References: <1346750580-11352-1-git-send-email-gaowanlong@cn.fujitsu.com>
	<20120904135924.b61e04e0.akpm@linux-foundation.org>
	<5046C4E7.5040407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gaowanlong@cn.fujitsu.com
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, open@kvack.org, list@kvack.org, MEMORY MANAGEMENT <linux-mm@kvack.org>

On Wed, 05 Sep 2012 11:20:07 +0800
Wanlong Gao <gaowanlong@cn.fujitsu.com> wrote:

> On 09/05/2012 04:59 AM, Andrew Morton wrote:
> > On Tue, 4 Sep 2012 17:23:00 +0800
> > Wanlong Gao <gaowanlong@cn.fujitsu.com> wrote:
> > 
> >> POSIX said that if the file is a regular file and the value of "off"
> >> plus "len" exceeds the offset maximum established in the open file
> >> description associated with fildes, mmap should return EOVERFLOW.
> > 
> > That's what POSIX says, but what does Linux do?  It is important that
> 
> Current Linux checks whether the shifted off+len exceed ULONG_MAX, it seems
> never happen.
> 
> > we precisely describe and understand the behaviour change, as there is
> > potential here to break existing applications.
> > 
> > I'm assuming that Linux presently permits the mmap() and then generates
> > SIGBUS if an access is attempted beyond the max file size?
> 
> What I saw is ENOMEM because the "len" here is too large.

I don't think I understand this.  You're saying that without your patch
applied, the mmap() attempt returns -ENOMEM?  If so, where in the code
does that occur?

In the current upstream kernel is there some combination of mmap()
arguments which will permit the mmap() to succeed, even though it
refers to a section of the file which lies beyond the file's maximum
offset?

> > 
> >> 	/* offset overflow? */
> >> -	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
> >> -               return -EOVERFLOW;
> >> +	if (off + len < off)
> >> +		return -EOVERFLOW;
> > 
> > Well, this treats sizeof(off_t) as the "offset maximum established in
> > the open file".  But from my reading of the above excerpt, we should in
> > fact be checking against the underlying fs's s_maxbytes?
> 
> More reasonable, how about following?

Well I don't know.  Again, the concern here is the risk of breaking
existing applications.  So before proceeding, we need a very complete
and accurate understanding of the kernel's behaviour both before and
after this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
