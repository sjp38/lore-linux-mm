Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 2BD076B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 10:16:40 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 25 Feb 2013 08:08:30 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id B225419D8048
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 08:08:05 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1PEwLqb314892
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 08:08:07 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1PEtjj6019923
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 07:55:45 -0700
Message-ID: <512B784E.5070002@linux.vnet.ibm.com>
Date: Mon, 25 Feb 2013 06:42:22 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] [v3] fix illegal use of __pa() in KVM code
References: <20130122212428.8DF70119@kernel.stglabs.ibm.com> <1361741338.21499.38.camel@thor.lan>
In-Reply-To: <1361741338.21499.38.camel@thor.lan>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Hurley <peter@hurleysoftware.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>

On 02/24/2013 01:28 PM, Peter Hurley wrote:
> Now that the alloc_remap() has been/is being removed, is most/all of
> this being reverted?

I _believe_ alloc_remap() is the only case where we actually remapped
low memory.  However, there is still other code that does __pa()
translations for percpu areas: per_cpu_ptr_to_phys().  I _think_ it's
still theoretically possible to get some percpu data in the vmalloc() area.

> So in short, my questions are:
> 1) is the slow_virt_to_phys() necessary anymore?

kvm_vcpu_arch has a

        struct pvclock_vcpu_time_info hv_clock;

and I believe I mistook the two 'hv_clock's for each other.  However,
this doesn't hurt anything, and the performance difference is probably
horribly tiny.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
