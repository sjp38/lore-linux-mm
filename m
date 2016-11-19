Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id E62956B049B
	for <linux-mm@kvack.org>; Sat, 19 Nov 2016 09:50:43 -0500 (EST)
Received: by mail-yw0-f199.google.com with SMTP id a10so110942438ywa.6
        for <linux-mm@kvack.org>; Sat, 19 Nov 2016 06:50:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p79si2840067ywp.320.2016.11.19.06.50.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Nov 2016 06:50:43 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAJEmpr0074803
	for <linux-mm@kvack.org>; Sat, 19 Nov 2016 09:50:43 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26tkfxage5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 19 Nov 2016 09:50:42 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 19 Nov 2016 07:50:42 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [HMM v13 00/18] HMM (Heterogeneous Memory Management) v13
In-Reply-To: <alpine.LNX.2.20.1611181638370.53648@blueforge.nvidia.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com> <alpine.LNX.2.20.1611181638370.53648@blueforge.nvidia.com>
Date: Sat, 19 Nov 2016 20:20:35 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Message-Id: <8760njmslg.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

John Hubbard <jhubbard@nvidia.com> writes:

> On Fri, 18 Nov 2016, J=C3=A9r=C3=B4me Glisse wrote:
>
>> Cliff note: HMM offers 2 things (each standing on its own). First
>> it allows to use device memory transparently inside any process
>> without any modifications to process program code. Second it allows
>> to mirror process address space on a device.
>>=20
>> Change since v12 is the use of struct page for device memory even if
>> the device memory is not accessible by the CPU (because of limitation
>> impose by the bus between the CPU and the device).
>>=20
>> Using struct page means that their are minimal changes to core mm
>> code. HMM build on top of ZONE_DEVICE to provide struct page, it
>> adds new features to ZONE_DEVICE. The first 7 patches implement
>> those changes.
>>=20
>> Rest of patchset is divided into 3 features that can each be use
>> independently from one another. First is the process address space
>> mirroring (patch 9 to 13), this allow to snapshot CPU page table
>> and to keep the device page table synchronize with the CPU one.
>>=20
>> Second is a new memory migration helper which allow migration of
>> a range of virtual address of a process. This memory migration
>> also allow device to use their own DMA engine to perform the copy
>> between the source memory and destination memory. This can be
>> usefull even outside HMM context in many usecase.
>>=20
>> Third part of the patchset (patch 17-18) is a set of helper to
>> register a ZONE_DEVICE node and manage it. It is meant as a
>> convenient helper so that device drivers do not each have to
>> reimplement over and over the same boiler plate code.
>>=20
>>=20
>> I am hoping that this can now be consider for inclusion upstream.
>> Bottom line is that without HMM we can not support some of the new
>> hardware features on x86 PCIE. I do believe we need some solution
>> to support those features or we won't be able to use such hardware
>> in standard like C++17, OpenCL 3.0 and others.
>>=20
>> I have been working with NVidia to bring up this feature on their
>> Pascal GPU. There are real hardware that you can buy today that
>> could benefit from HMM. We also intend to leverage this inside the
>> open source nouveau driver.
>>=20
>
> Hi,
>
> We (NVIDIA engineering) have been working closely with Jerome on this for=
=20
> several years now, and I wanted to mention that NVIDIA is committed to=20
> using HMM. We've done initial testing of this patchset on Pascal GPUs (a=
=20
> bit more detail below) and it is looking good.
>=20=20=20

This can also be used on IBM platforms like Minsky (
http://www.tomshardware.com/news/ibm-power8-nvidia-tesla-p100-minsky,32661.=
html
)

There is also discussion around using this for device accelerated page
migration. That can help with coherent device memory node work.
(https://lkml.kernel.org/r/1477283517-2504-1-git-send-email-khandual@linux.=
vnet.ibm.com)

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
