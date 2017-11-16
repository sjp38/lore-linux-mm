Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 765FE6B0033
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 18:12:00 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id g139so355921oic.12
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 15:12:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w131si705036oib.455.2017.11.16.15.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Nov 2017 15:11:59 -0800 (PST)
Date: Thu, 16 Nov 2017 18:11:55 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Message-ID: <20171116231155.GA5640@redhat.com>
References: <0d7273c3-181c-6d68-3c5f-fa518e782374@huawei.com>
 <20170930224927.GC6775@redhat.com>
 <CAA_GA1dhrs7n-ewZmW4bNtouK8rKnF1_TWv0z+2vrUgJjWpnMQ@mail.gmail.com>
 <20171012153721.GA2986@redhat.com>
 <CAAsGZS7JeH-cxrmZAVraLm5RjSVHJLXMdwZQ7Cxm91KGdVQocg@mail.gmail.com>
 <20171116024425.GC2934@redhat.com>
 <CAAsGZS5eoSK=Hd5av2bkw=chPGyfOYYNbrdizzCqq2gZ7+XH_g@mail.gmail.com>
 <CAAsGZS43n2_f9sQXGH5Ap=eEx2f099CDwHC0aTTgOEbw7Dc=zg@mail.gmail.com>
 <20171116212904.GA4823@redhat.com>
 <CAAsGZS7oCjHuUTUAUadb+F+drp3KgDARuaOaSBbW-8RWbJBDMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAAsGZS7oCjHuUTUAUadb+F+drp3KgDARuaOaSBbW-8RWbJBDMA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: chetan L <loke.chetan@gmail.com>
Cc: Bob Liu <lliubbo@gmail.com>, David Nellans <dnellans@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-accelerators@lists.ozlabs.org

On Thu, Nov 16, 2017 at 02:41:39PM -0800, chetan L wrote:
> On Thu, Nov 16, 2017 at 1:29 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> 
> >
> > For the NUMA discussion this is related to CPU less node ie not wanting
> > to add any more CPU less node (node with only memory) and they are other
> > aspect too. For instance you do not necessarily have good informations
> > from the device to know if a page is access a lot by the device (this
> > kind of information is often only accessible by the device driver). Thus
> 
> @Jerome - one comment w.r.t 'do not necessarily have good info on
> device access'.
> 
> So you could be assuming a few things here :). CCIX extends the CPU
> complex's coherency domain(it is now a single/unified coherency
> domain). The CCIX-EP (lets say an accelerator/XPU or a NIC or a combo)
> is now a true peer w.r.t the host-numa-node(s) (aka 1st class
> citizen). I don't know how much info was revealed at the latest ARM
> techcon where CCIX was presented. So I cannot divulge any further
> details until I see that slide deck. However, you can safely assume
> that the host will have *all* the info w.r.t the device-access and
> vice-versa.

I do have access to CCIX, last time i read the draft, few month ago,
my understanding was that there is no mechanism to differentiate between
device behind the root complex. So when you do autonuma you don't know
which of your CCIX device is the one faulting hence you can not keep
track of that inside struct page for autonuma (ignoring the issue with
the lack of CPUID for each device).

This is what i mean by NUMA is not a good fit as it is. Yes everything
is cache coherent and all, but that is just a small part of what is
needed to make autonuma as it is today work.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
