Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 505396B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 11:46:19 -0400 (EDT)
Message-ID: <4F7DBE00.9070800@freebox.fr>
Date: Thu, 05 Apr 2012 17:45:04 +0200
From: Florian Fainelli <ffainelli@freebox.fr>
MIME-Version: 1.0
Subject: Re: Caching issues with tmpfs?
References: <4F7DB53D.9070508@freebox.fr>
In-Reply-To: <4F7DB53D.9070508@freebox.fr>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi again Hugh,

Le 04/05/12 17:07, Florian Fainelli a A(C)crit :
> Hi Hugh,
>
> I am encountering a very weird and serious issue with tmpfs, which I
> have seen both in 2.6.39 and 3.2.13. The issue is the following:
>
> 1) I read a file from a NAND device back to /tmp/bar
> 2) /tmp/bar is loopback mounted to /tmp/bar_mount/
> 3) when I list the contents of /tmp/bar_mount I see only half of my
> files, and using hexdump on /tmp/bar shows that the cramfs header is
> correct and contains all, which rules out the cramfs issue
> 4) if I move /tmp/bar to /tmp/bar.move and loopback mount /tmp/bar.move
> to /tmp/bar_mount, I now see all the files present
>
> I have compared the md5sums of the cramfs file before mounting, after
> mounting, before moving, after moving, they are all the same. Also, the
> loopback mount does not yiel when mounting the cramfs file, which rules
> out its bad integrity.
>
> the /tmp directory is mounted with the defaults attributes (rw,relatime).
>
> My system is a x86 Atom-based System-on-a-Chip and should not suffer
> from the CPU data cache aliasing issue mentioned here:
> http://lkml.indiana.edu/hypermail/linux/kernel/1202.0/00090.html
>
> I backported this patch however, and it does not make any difference as
> expected.
>
> This behavior has been observed on several devices.
>
> I will try to provide you with a test case to reproduce the issue,
> meanwhile any hints are appreciated :)

I am terribly sorry for suspecting tmpfs, the issue is actually in 
busybox, which is smart enough not to delete the loop device after an 
umount and keep a stale copy of the file used as source. Consequent 
mounts are then given the same stale copy because the name of the source 
file matches the non-deleted loopback setup.
--
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
