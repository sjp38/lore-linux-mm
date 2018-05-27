Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3CD8E6B0007
	for <linux-mm@kvack.org>; Sun, 27 May 2018 09:03:36 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id n8-v6so3962759wmc.1
        for <linux-mm@kvack.org>; Sun, 27 May 2018 06:03:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v82-v6si8200368wmv.146.2018.05.27.06.03.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 May 2018 06:03:34 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4RCxU5B103531
	for <linux-mm@kvack.org>; Sun, 27 May 2018 09:03:33 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2j7mg3n322-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 27 May 2018 09:03:33 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 27 May 2018 14:03:31 +0100
Date: Sun, 27 May 2018 16:03:26 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
 <20180418193220.4603-3-timofey.titovets@synesis.ru>
 <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
 <CAGqmi76gJV=ZDX5=Y3toF2tPiJs8T=PiUJFQg5nq9O5yztx80Q@mail.gmail.com>
 <CAGM2reaZ2YoxFhEDtcXi=hMFoGFi8+SROOn+_SRMwnx3cW15kw@mail.gmail.com>
 <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAGqmi76-qK9q_OTvyqpb-9k_m0CLMt3o860uaN5LL8nBkf5RTg@mail.gmail.com>
Message-Id: <20180527130325.GB4522@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: pasha.tatashin@oracle.com, linux-mm@kvack.org, Sioh Lee <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

Hi,

On Thu, May 24, 2018 at 11:01:20AM +0300, Timofey Titovets wrote:
> N?N?, 23 D 1/4 D?N? 2018 D3. D2 17:24, Pavel Tatashin <pasha.tatashin@oracle.com>:
> 
> > Hi Timofey,

[ ... ]
 
> > It really feels wrong to keep  choice_fastest_hash() in fasthash(), it is
> > done only once and really belongs to the init function, like ksm_init().
> As
> 
> That possible to move decision from lazy load, to ksm_thread,
> that will allow us to start bench and not slowdown boot.
> 
> But for that to works, ksm must start later, after init of crypto.
 
What about moving choice_fastest_hash() to run_store()?

KSM anyway starts with ksm_run = KSM_RUN_STOP and does not scan until
userspace writes !0 to /sys/kernel/mm/ksm/run.

Selection of the hash function when KSM is actually enabled seems quite
appropriate...

> > I understand, you think it is a bad idea to keep it in ksm_init() because
> > it slows down boot by 0.25s, which I agree with your is substantial. But,
> I
> > really do not think that we should spend those 0.25s at all deciding what
> > hash function is optimal, and instead default to one or another during
> boot
> > based on hardware we are booting on. If crc32c without hw acceleration is
> > no worse than jhash2, maybe we should simply switch to  crc32c?
> 
> crc32c with no hw, are slower in compare to jhash2 on x86, so i think on
> other arches result will be same.
> 
> > Thank you,
> > Pavel
> 
> Thanks.
> 
> --
> Have a nice day,
> Timofey.
> 

-- 
Sincerely yours,
Mike.
