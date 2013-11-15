Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 504616B0031
	for <linux-mm@kvack.org>; Fri, 15 Nov 2013 13:42:54 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id p10so3822635pdj.37
        for <linux-mm@kvack.org>; Fri, 15 Nov 2013 10:42:53 -0800 (PST)
Received: from psmtp.com ([74.125.245.150])
        by mx.google.com with SMTP id yk3si2713597pac.244.2013.11.15.10.42.52
        for <linux-mm@kvack.org>;
        Fri, 15 Nov 2013 10:42:52 -0800 (PST)
Date: Fri, 15 Nov 2013 13:30:02 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 0/3] Early use of boot service memory
Message-ID: <20131115183002.GE6637@redhat.com>
References: <CAOJsxLFkHQ6_f+=CMwfNLykh59TZH5VrWeVEDPCWPF1wiw7tjQ@mail.gmail.com>
 <20131114180455.GA32212@anatevka.fc.hp.com>
 <CAOJsxLFWMi8DoFp+ufri7XoFO27v+2=0oksh8+NhM6P-OdkOwg@mail.gmail.com>
 <20131115005049.GJ5116@anatevka.fc.hp.com>
 <20131115062417.GB9237@gmail.com>
 <CAE9FiQWzSTtW8N=0hoUe6iCSM-k64Mv97n0whAS0_vZ+psuOsg@mail.gmail.com>
 <5285C639.5040203@zytor.com>
 <20131115140738.GB6637@redhat.com>
 <CAE9FiQUnw9Ujmdtq-AgC4VctQ=fZSBkzehoTbvw=aZeARL+pwA@mail.gmail.com>
 <52865CA1.5020309@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52865CA1.5020309@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Ingo Molnar <mingo@kernel.org>, jerry.hoemann@hp.com, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86 maintainers <x86@kernel.org>, Matt Fleming <matt.fleming@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-efi@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 15, 2013 at 09:40:49AM -0800, H. Peter Anvin wrote:
> On 11/15/2013 09:33 AM, Yinghai Lu wrote:
> > 
> > If the system support intel IOMMU, we only need to that 72M for SWIOTLB
> > or AMD workaround.
> > If the user really care that for intel iommu enable system, they could use
> > "crashkernel=0,low" to have that 72M back.
> > 
> > and that 72M is under 4G instead of 896M.
> > 
> > so reserve 72M is not better than reserve 128M?
> > 
> 
> Those 72M are in addition to 128M, which does add up quite a bit.
> However, the presence of a working IOMMU in the system is something that
> should be possible to know at setup time.
> 

And IOMMU support is very flaky with kdump. And IOMMU's can be turned
off at command line. And that would force one to remove crahkernel_low=0.
So change of one command line option forces change of another. It is
complicated.

Also there are very few systems which work with IOMMU on. A lot more
which work without IOMMU. We have all these DMAR issues and still nobody
has been able to address IOMMU issues properly.

> Now, this was discussed partly in the context of VMs.  I want to say, as
> I have again and again: the right way to dump a VM is with hypervisor
> assistance rather than an in-image dumper which is both expensive and
> may be corrupted by the failure.

I agree taking assistance of hypervisor should be useful.

One reason we use kdump for VM too because it makes life simple. There
is no difference in how we configure, start and manage crash dumps
in baremetal or inside VM. And in practice have not heard of lot of
failures of kdump in VM environment.

So while reliability remains a theoritical concern, in practice it
has not been a real concern and that's one reason I think we have
not seen a major push for alternative method in VM environment.

> 
> It would be good if the various VMs with interest in Linux would agree
> on a mechanism for launching a dumper.  This can be done either inband
> (on the execution of a specific hypercall, the hypervisor terminates I/O
> to the guest, inserts a dumper into the address space and launches it)
> or out-of-band (the hypervisor itself, or an assistant program, writes a
> dump file) or as a hybrid (a new dump guest is launched with the
> hypervisor-written or hypervisor-preserved crashed guest image somehow
> passed to it.)

virsh can take dumps of KVM guest, so hypervisor calling out to an
assistant program might help here.

Anyway, we will gladly use any new dump mechanism for VM once things
start working seamlessly. So till all this materializes, forcing user
to reserve that extra 72M concerns me (both in bare-metal and virtualized
environments).

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
