Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 543A48E0002
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:01:46 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l14-v6so6998494oii.9
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 11:01:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b42-v6si695768otd.72.2018.09.13.11.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 11:01:44 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8DHsLjq011635
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:01:43 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mfvaa9476-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:01:41 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 13 Sep 2018 19:01:39 +0100
Date: Thu, 13 Sep 2018 21:01:33 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
References: <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
 <20180527130325.GB4522@rapoport-lnx>
 <CAGM2rea2GBvOAiKcSpHkQ9F+jgvy3sCsBw7hFz26DvQ+c_677A@mail.gmail.com>
 <CAGqmi74G-7bM5mbbaHjzOkTvuEpCcAbZ8Q0PVCMkyP09XaVSkA@mail.gmail.com>
 <20180607115232.GA8245@rapoport-lnx>
 <CAGM2rebK=gNbcAwkmt7W9kwtd=QWoPRogQMaoXOv=bmX+_d+yw@mail.gmail.com>
 <20180625084806.GB13791@rapoport-lnx>
 <CAGqmi75emzhU_coNv_8qaf1LkdG7gsFWNAFTwUC+1FikH7h1WQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAGqmi75emzhU_coNv_8qaf1LkdG7gsFWNAFTwUC+1FikH7h1WQ@mail.gmail.com>
Message-Id: <20180913180132.GB15191@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, linux-mm@kvack.org, Sioh Lee <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

(updated Pasha's e-mail)

Thu, Sep 13, 2018 at 01:35:20PM +0300, Timofey Titovets wrote:
> D?D 1/2 , 25 D,N?D 1/2 . 2018 D3. D2 11:48, Mike Rapoport <rppt@linux.vnet.ibm.com>:
> >
> > On Thu, Jun 07, 2018 at 09:29:49PM -0400, Pavel Tatashin wrote:
> > > > With CONFIG_SYSFS=n there is nothing that will set ksm_run to anything but
> > > > zero and ksm_do_scan will never be called.
> > > >
> > >
> > > Unfortunatly, this is not so:
> > >
> > > In: /linux-master/mm/ksm.c
> > >
> > > 3143#else
> > > 3144 ksm_run = KSM_RUN_MERGE; /* no way for user to start it */
> > > 3145
> > > 3146#endif /* CONFIG_SYSFS */
> > >
> > > So, we do set ksm_run to run right from ksm_init() when CONFIG_SYSFS=n.
> > >
> > > I wonder if this is acceptible to only use xxhash when CONFIG_SYSFS=n ?
> >
> > BTW, with CONFIG_SYSFS=n KSM may start running before hardware acceleration
> > for crc32c is initialized...
> >
> > > Thank you,
> > > Pavel
> > >
> >
> > --
> > Sincerely yours,
> > Mike.
> >
> 
> Little thread bump.
> That patchset can't move forward already for about ~8 month.
> As i see main question in thread: that we have a race with ksm
> initialization and availability of crypto api.
> Maybe we then can fall back to simple plan, and just replace old good
> buddy jhash by just more fast xxhash?
> That allow move question with crypto api & crc32 to background, and
> make things better for now, in 2-3 times.
> 
> What you all think about that?

Sounds reasonable to me

> > crc32c_intel: 1084.10ns
> > crc32c (no hardware acceleration): 7012.51ns
> > xxhash32: 2227.75ns
> > xxhash64: 1413.16ns
> > jhash2: 5128.30ns
> 
> -- 
> Have a nice day,
> Timofey.
> 

-- 
Sincerely yours,
Mike.
