Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 986DC6B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 14:53:47 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Uruqf-0003hj-Av
	for linux-mm@kvack.org; Wed, 26 Jun 2013 20:53:45 +0200
Received: from c-24-17-197-101.hsd1.wa.comcast.net ([24.17.197.101])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 26 Jun 2013 20:53:45 +0200
Received: from eternaleye by c-24-17-197-101.hsd1.wa.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 26 Jun 2013 20:53:45 +0200
From: Alex Elsayed <eternaleye@gmail.com>
Subject: Re: RFC: named anonymous vmas
Date: Wed, 26 Jun 2013 11:53:32 -0700
Message-ID: <kqfdb6$haq$2@ger.gmane.org>
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com> <20130622103158.GA16304@infradead.org> <CAMbhsRTz246dWPQOburNor2HvrgbN-AWb2jT_AEywtJHFbKWsA@mail.gmail.com> <kq4v0b$p8p$3@ger.gmane.org> <20130624114832.GA9961@infradead.org> <CAMbhsRTdMaVR1LZRigumDqz_e5FgeyfJLrSHCDs8t7ywrmumTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Colin Cross wrote:

> On Mon, Jun 24, 2013 at 4:48 AM, Christoph Hellwig <hch@infradead.org>
> wrote:
>> On Sat, Jun 22, 2013 at 12:47:29PM -0700, Alex Elsayed wrote:
>>> Couldn't this be done by having a root-only tmpfs, and having a
>>> userspace component that creates per-app directories with restrictive
>>> permissions on startup/app install? Then each app creates files in its
>>> own directory, and can pass the fds around.
> 
> If each app gets its own writable directory that's not really
> different than a world writable tmpfs.  It requires something that
> watches for apps to exit for any reason and cleans up their
> directories, and it requires each app to come up with an unused name
> when it wants to create a file, and the kernel can give you both very
> cleanly.

Not so far as I can tell. I'm thinking specifically in the Android model of 
'one user per app', and as I see it the issues with a world writable tmpfs 
would be:

1.) Race conditions and all the sticky bit bugs of history - app A tries to 
create file foo, but app C is doing the same. This is resolved with per-app 
directories and restrictive permissions.

2.) Resource exhaustion - implementing this for a mmap'ed device node as 
described in HCH's mail would amount to implementing some sort of quota 
support. A world-writable tmpfs would require user quotas. A dir-per-app 
tmpfs could mount a separate, limited tmpfs on each even in the absence of 
user quotas, and mount -o remount,size=$foo works to change those limits 
(within certain bounds of behavior).

3.) Cleanup - doing this with a device makes it simple, yes; once the FDs 
are closed the mapping goes away. But if the only way the mapping gets 
shared is via FD passing, and your users are all via a platform library, 
unlink() after open(O_CREAT) would get you the same behavior as I understand 
it. At that point, the only thing to clean up is the per-app directory 
itself, which can be done on app uninstall IIUC.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
