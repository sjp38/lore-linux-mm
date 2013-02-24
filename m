Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 7C2A56B0005
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 20:47:03 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Sat, 23 Feb 2013 20:47:02 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 9A288C9001B
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 20:46:59 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1O1kx8S326646
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 20:46:59 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1O1kxQm005066
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 22:46:59 -0300
Message-ID: <5129710F.6060804@linux.vnet.ibm.com>
Date: Sat, 23 Feb 2013 17:46:55 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
References: <1361660281-22165-1-git-send-email-psusi@ubuntu.com> <1361660281-22165-2-git-send-email-psusi@ubuntu.com>
In-Reply-To: <1361660281-22165-2-git-send-email-psusi@ubuntu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: linux-mm@kvack.org

On 02/23/2013 02:58 PM, Phillip Susi wrote:
> 2) Discarding pages under low cache pressure is a waste
> 3) It was useless on files being written, and thus full of dirty pages
> 
> Now we just move the pages to the inactive list so they will be reclaimed
> sooner.

Folks actually use this in practice to flush the page cache out:

http://git.sr71.net/?p=eyefi-config.git;a=blob;f=eyefi-linux.c;h=b77a891995109f6caa288925a13985cc495d7b2d;hb=HEAD#l62

I have really good reasons for really wanting to be _rid_ of the page
cache no matter how much memory pressure there is.

I've seen people at IBM using this to ensure that they stay out of
memory reclaim completely.  I don't completely agree with the approach,
but this would completely ruin their performance since the VM-initiated
writeout is so relatively slow for them.

I think this patch is a really bad idea.  If you want the behavior
you're proposing, I'd suggest using another flag.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
