Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 0FB116B005D
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:12:22 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 10 Jan 2013 18:12:22 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 596FDC9003C
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:12:19 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0ANCJ1L308240
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:12:19 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0ANCIp6024676
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 21:12:18 -0200
Message-ID: <50EF4AD1.4060807@linux.vnet.ibm.com>
Date: Thu, 10 Jan 2013 15:12:17 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Reproducible OOM with partial workaround
References: <201301102158.r0ALwI4i031014@como.maths.usyd.edu.au>
In-Reply-To: <201301102158.r0ALwI4i031014@como.maths.usyd.edu.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org

On 01/10/2013 01:58 PM, paul.szabo@sydney.edu.au wrote:
> I developed a workaround patch for this particular OOM demo, dropping
> filesystem caches when about to exhaust lowmem. However, subsequently
> I observed OOM when running many processes (as yet I do not have an
> easy-to-reproduce demo of this); so as I suspected, the essence of the
> problem is not with FS caches.
> 
> Could you please help in finding the cause of this OOM bug?

As was mentioned in the bug, your 32GB of physical memory only ends up
giving ~900MB of low memory to the kernel.  Of that, around 600MB is
used for "mem_map[]", leaving only about 300MB available to the kernel
for *ALL* of its allocations at runtime.

Your configuration has never worked.  This isn't a regression, it's
simply something that we know never worked in Linux and it's a very hard
problem to solve.  One Linux vendor (at least) went to a huge amount of
trouble to develop, ship, and supported a kernel that supported large
32-bit machines, but it was never merged upstream and work stopped on it
when such machines became rare beasts:

	http://lwn.net/Articles/39925/

I believe just about any Linux vendor would call your configuration
"unsupported".  Just because the kernel can boot does not mean that we
expect it to work.

It's possible that some tweaks of the vm knobs (like lowmem_reserve)
could help you here.  But, really, you don't want to run a 32-bit kernel
on such a large machine.  Very, very few folks are running 32-bit
kernels on these systems and you're likely to keep running in to bugs
because this is such a rare configuration.

We've been very careful to ensure that 64-bit kernels shoul basically be
drop-in replacements for 32-bit ones.  You can keep userspace 100%
32-bit, and just have a 64-bit kernel.

If you're really set on staying 32-bit, I might have a NUMA-Q I can give
you. ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
