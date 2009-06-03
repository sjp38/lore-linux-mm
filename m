Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 781716B005A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:19:36 -0400 (EDT)
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
From: Stephen Smalley <sds@tycho.nsa.gov>
In-Reply-To: <alpine.DEB.1.10.0906031047390.15621@gentwo.org>
References: <20090530192829.GK6535@oblivion.subreption.com>
	 <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain>
	 <20090530230022.GO6535@oblivion.subreption.com>
	 <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>
	 <20090531022158.GA9033@oblivion.subreption.com>
	 <alpine.DEB.1.10.0906021130410.23962@gentwo.org>
	 <20090602203405.GC6701@oblivion.subreption.com>
	 <alpine.DEB.1.10.0906031047390.15621@gentwo.org>
Content-Type: text/plain
Date: Wed, 03 Jun 2009 11:11:54 -0400
Message-Id: <1244041914.12272.64.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: "Larry H." <research@subreption.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>

On Wed, 2009-06-03 at 10:50 -0400, Christoph Lameter wrote:
> On Tue, 2 Jun 2009, Larry H. wrote:
> 
> > Why would mmap_min_addr have been created in first place, if NULL can't
> > be mapped to force the kernel into accessing userland memory? This is
> > the way a long list of public and private kernel exploits have worked to
> > elevate privileges, and disable SELinux/LSMs atomically, too.
> >
> > Take a look at these:
> > http://www.grsecurity.net/~spender/exploit.tgz (disables LSMs)
> > http://milw0rm.com/exploits/4172
> > http://milw0rm.com/exploits/3587
> >
> > I would like to know what makes you think I can't mmap(0) from within
> > the same process that triggers your 'not so exploitable NULL page
> > fault', which instead of generating the oops will lead to 100% reliable,
> > cross-arch exploitation to get root privileges (again, after disabling
> > SELinux and anything else that would supposedly prevent this situation).
> > Or leaked memory, like a kmalloc(0) situation will most likely lead to,
> > given the current circumstances.
> 
> Ok. So what we need to do is stop this toying around with remapping of
> page 0. The following patch contains a fix and a test program that
> demonstrates the issue.
> 
> 
> Subject: [Security] Do not allow remapping of page 0 via MAP_FIXED
> 
> If one remaps page 0 then the kernel checks for NULL pointers of various
> flavors are bypassed and this may be exploited in various creative ways
> to transfer data from kernel space to user space.
> 
> Fix this by not allowing the remapping of page 0. Return -EINVAL if
> such a mapping is attempted.

You can already prevent unauthorized processes from mapping low memory
via the existing mmap_min_addr setting, configurable via
SECURITY_DEFAULT_MMAP_MIN_ADDR or /proc/sys/vm/mmap_min_addr.  Then
cap_file_mmap() or selinux_file_mmap() will apply a check when a process
attempts to map memory below that address.

-- 
Stephen Smalley
National Security Agency

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
