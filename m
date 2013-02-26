Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 4D9D96B0005
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 07:45:43 -0500 (EST)
Message-ID: <1361882727.3235.14.camel@thor.lan>
Subject: Re: [PATCH 0/5] [v3] fix illegal use of __pa() in KVM code
From: Peter Hurley <peter@hurleysoftware.com>
Date: Tue, 26 Feb 2013 07:45:27 -0500
In-Reply-To: <512B784E.5070002@linux.vnet.ibm.com>
References: <20130122212428.8DF70119@kernel.stglabs.ibm.com>
	 <1361741338.21499.38.camel@thor.lan> <512B784E.5070002@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon, 2013-02-25 at 06:42 -0800, Dave Hansen wrote:
> On 02/24/2013 01:28 PM, Peter Hurley wrote:
> > Now that the alloc_remap() has been/is being removed, is most/all of
> > this being reverted?
> 
> I _believe_ alloc_remap() is the only case where we actually remapped
> low memory.  However, there is still other code that does __pa()
> translations for percpu areas: per_cpu_ptr_to_phys().  I _think_ it's
> still theoretically possible to get some percpu data in the vmalloc() area.
> 
> > So in short, my questions are:
> > 1) is the slow_virt_to_phys() necessary anymore?

Ah, yep. Thanks for pointing out per_cpu_ptr_to_phys().

> kvm_vcpu_arch has a
> 
>         struct pvclock_vcpu_time_info hv_clock;
> 
> and I believe I mistook the two 'hv_clock's for each other.  However,
> this doesn't hurt anything, and the performance difference is probably
> horribly tiny.

Ok. It was confusing because the fixmap of that same phys memblock done
by pvclock was broken and I couldn't understand why the hvclock memblock
needed to be looked-up per cpu. Mystery solved.

Regards,
Peter Hurley


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
