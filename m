Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9633EC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 15:36:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 565352083D
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 15:36:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="aZpreJfZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 565352083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B53046B0006; Tue, 19 Mar 2019 11:36:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B05D46B0007; Tue, 19 Mar 2019 11:36:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F68C6B0008; Tue, 19 Mar 2019 11:36:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 66A856B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:36:52 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id s12so10021059oth.14
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 08:36:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=1unbtIvY5Ht57/xExEoU7Ql118n/fJ7lA1QdHqj8Odk=;
        b=JIsf20XG/sJJLteGKENuS5RE9PC/S/EIYF1DvCXHk9V3bXx2JdpHAHiJfSbcSv4Rhp
         rjSFmyPDdS16h1RsFCdpKEWcQIXipTqrG6JvRMvOgSign5v2bVnAsDHi/+6/4B7kY682
         MHKH7hSOPy6amPTln69eQVOVQ735Mp+qGfQu34HFuKV5YGpcQIM0g4yR8YWStKMJoAOU
         BscmSuYRYct34HoZLxvT6F1k53Zq+DcQRqRhQ0J9E4vPWZVm/alBLaHNfPdgQP3nRys4
         1tzB3kxmURxdVa8ITMDakX6r6v55h17bsbQaCSGg6o2Kd1V6TyfUz0tzeC4SOutmX6h7
         jqYQ==
X-Gm-Message-State: APjAAAVwzpcqq3bDSXth+LMBbhgjEH/vTtCovhL7ItcX0cSdSH3wil6o
	Yh7WGdB6cJ9jL/FCYW+r7vnTBAykMfvbufvCCdZ8Qfx+Vs/FQK0Pqlq8zGt1OTlhMTfgCSdbv3z
	V4IHIBs11bwDhD6xsxVxhH/8GE/u8hT7RSRUfGKLvW3INs6epf/wHaIyHdkr+qyuHPg==
X-Received: by 2002:a9d:651a:: with SMTP id i26mr1965081otl.140.1553009812003;
        Tue, 19 Mar 2019 08:36:52 -0700 (PDT)
X-Received: by 2002:a9d:651a:: with SMTP id i26mr1965027otl.140.1553009811121;
        Tue, 19 Mar 2019 08:36:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553009811; cv=none;
        d=google.com; s=arc-20160816;
        b=07prUTAIo7xO1ZEmYFGvwSWKE2Ca/+D0qZH6joqYMsKcb4VrVPkz5T6Nuj8en8l0kK
         xU558gkV/AftiaBvzdGofFxBWzoyw25/3bxywlnaSMSxkMv+qs/Q9Duol5S1LY8ZdDQh
         unPemH4kKdDR1BIlEDK+2GSq/Qu1xa0on1HESkqSDHTdTmEHGnTkV0j/cceFrGy0zkx0
         j6DYGD0ckPrcr7S2xBjGC3OSUoZF5RBzcQIUx58UH8XnA5lLKtkGWGQy+afu/pCb1DxF
         pCC+tjMVKfcOoLixKcVQggMR0G0bHN4q3jtjoV+UQnyH+mRs4FLnT1abOW8ji/3dfI/V
         Q/vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=1unbtIvY5Ht57/xExEoU7Ql118n/fJ7lA1QdHqj8Odk=;
        b=iHlYDkYTxLqNPZQya7LP/do3GTwisRlizE4tacJgktGhYcisa9YT1aR92oLAUsLD4q
         aenEyMT6YKd7tBqu4zl2bwFxihMhGFB+zUfjNuW0Plx4y9W+A9Euvw06kaehUoal8dBr
         ZYmbxiXxTD8qpPBmWiZD6X9ERIM+Xhf3yS/e91o3Ii7jiOOJwj83g7pPygY6Uoy3wPJz
         AXf0SLV+EmqQWnGSlz3yEUVEuovDlzhRWILsDGdbRtDtXRKD2SR3qqK2poBlG3BUnNTs
         C420S39gqAkw0IUE6E8vw/CtpaJwQmwi4vPozucp9hq0Hh9HS+8ZqZjFIXlGa1dQ5KvM
         gQ9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aZpreJfZ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o16sor7659173otl.176.2019.03.19.08.36.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 08:36:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=aZpreJfZ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=1unbtIvY5Ht57/xExEoU7Ql118n/fJ7lA1QdHqj8Odk=;
        b=aZpreJfZigo3FKFLPUZju3pojwCEccRahWR3gpAo6ZfCqnm80KEjECkjhF+s7IRotx
         5hw8tXb+CaJesSAIWhgcGCpQA7hZzzrZ+9f9SO7gvkUW5tGowDM/3iommlzv6U6burYI
         BNmd+EJvqFeLxFn81SfbhyntCt4bNsllLQoFNgz1f2lITd61wl+htoOGhnjBl014kN16
         IUmyQXlvPOSXPDY++j0eWwbcpoyyqtUpOsmNnsshnqRnsUDfJiLYo9EeHXeyyaz763AC
         q8MEBln0Af2RbQ8eLac+I5cLVBSiQ1cCA2cpKMnBa4WuGFMYa31AV8rxXkUOkAyb1YHe
         A1+A==
X-Google-Smtp-Source: APXvYqxPZKAs3Uy3oIgghMayYyNVrb3KfDYOGyNEqIq7hCNaT+fTAAGNpB3SAeibiLTtMxkc/Xc9qQ6zh78W8KexrOw=
X-Received: by 2002:a9d:2c23:: with SMTP id f32mr1985166otb.353.1553009810711;
 Tue, 19 Mar 2019 08:36:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
 <87k1hc8iqa.fsf@linux.ibm.com> <20190306124453.126d36d8@naga.suse.cz>
 <df01bf6e-84a1-53fb-bf0c-0957af2f79e1@linux.ibm.com> <CAPcyv4iLm09DSiF3niFprP3PTFrgB5pZPp9AysBpRa-m725tmw@mail.gmail.com>
 <20190319084439.eya2pisiirattuil@kshutemo-mobl1>
In-Reply-To: <20190319084439.eya2pisiirattuil@kshutemo-mobl1>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 19 Mar 2019 08:36:38 -0700
Message-ID: <CAPcyv4jAMAenu-WJ1P9E-q728OVpvcajPxqPrW0+gQg_Jk1+0g@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, =?UTF-8?Q?Michal_Such=C3=A1nek?= <msuchanek@suse.de>, 
	Oliver <oohall@gmail.com>, Jan Kara <jack@suse.cz>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Ross Zwisler <zwisler@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 1:45 AM Kirill A. Shutemov <kirill@shutemov.name> w=
rote:
>
> On Wed, Mar 13, 2019 at 09:07:13AM -0700, Dan Williams wrote:
> > On Wed, Mar 6, 2019 at 4:46 AM Aneesh Kumar K.V
> > <aneesh.kumar@linux.ibm.com> wrote:
> > >
> > > On 3/6/19 5:14 PM, Michal Such=C3=A1nek wrote:
> > > > On Wed, 06 Mar 2019 14:47:33 +0530
> > > > "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
> > > >
> > > >> Dan Williams <dan.j.williams@intel.com> writes:
> > > >>
> > > >>> On Thu, Feb 28, 2019 at 1:40 AM Oliver <oohall@gmail.com> wrote:
> > > >>>>
> > > >>>> On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
> > > >>>> <aneesh.kumar@linux.ibm.com> wrote:
> > > >
> > > >> Also even if the user decided to not use THP, by
> > > >> echo "never" > transparent_hugepage/enabled , we should continue t=
o map
> > > >> dax fault using huge page on platforms that can support huge pages=
.
> > > >
> > > > Is this a good idea?
> > > >
> > > > This knob is there for a reason. In some situations having huge pag=
es
> > > > can severely impact performance of the system (due to host-guest
> > > > interaction or whatever) and the ability to really turn off all THP
> > > > would be important in those cases, right?
> > > >
> > >
> > > My understanding was that is not true for dax pages? These are not
> > > regular memory that got allocated. They are allocated out of /dev/dax=
/
> > > or /dev/pmem*. Do we have a reason not to use hugepages for mapping
> > > pages in that case?
> >
> > The problem with the transparent_hugepage/enabled interface is that it
> > conflates performing compaction work to produce THP-pages with the
> > ability to map huge pages at all.
>
> That's not [entirely] true. transparent_hugepage/defrag gates heavy-duty
> compaction. We do only very limited compaction if it's not advised by
> transparent_hugepage/defrag.
>
> I believe DAX has to respect transparent_hugepage/enabled. Or not
> advertise its huge pages as THP. It's confusing for user.

What does "advertise its huge pages as THP" mean in practice? I think
it's confusing that DAX, a facility that bypasses System RAM, is
affected by a transparent_hugepage flag which is a feature for
combining System RAM pages into larger pages. For the same reason that
transparent_hugepage does not gate / control hugetlb operation is the
same reason that transparent_hugepage should not gate / control DAX. A
global setting to disable opportunistic large page mappings of
System-RAM makes sense, but I don't see why that should read on DAX?

