Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A34206B0069
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 16:59:25 -0400 (EDT)
Date: Tue, 4 Sep 2012 13:59:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: fix mmap overflow checking
Message-Id: <20120904135924.b61e04e0.akpm@linux-foundation.org>
In-Reply-To: <1346750580-11352-1-git-send-email-gaowanlong@cn.fujitsu.com>
References: <1346750580-11352-1-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "open list:MEMORY
 MANAGEMENT" <linux-mm@kvack.org>

On Tue, 4 Sep 2012 17:23:00 +0800
Wanlong Gao <gaowanlong@cn.fujitsu.com> wrote:

> POSIX said that if the file is a regular file and the value of "off"
> plus "len" exceeds the offset maximum established in the open file
> description associated with fildes, mmap should return EOVERFLOW.

That's what POSIX says, but what does Linux do?  It is important that
we precisely describe and understand the behaviour change, as there is
potential here to break existing applications.

I'm assuming that Linux presently permits the mmap() and then generates
SIGBUS if an access is attempted beyond the max file size?

> 	/* offset overflow? */
> -	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
> -               return -EOVERFLOW;
> +	if (off + len < off)
> +		return -EOVERFLOW;

Well, this treats sizeof(off_t) as the "offset maximum established in
the open file".  But from my reading of the above excerpt, we should in
fact be checking against the underlying fs's s_maxbytes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
