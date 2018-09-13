Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id E6C7B8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 17:34:42 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r131-v6so7620314oie.14
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:34:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c14-v6sor1517168otk.34.2018.09.13.14.34.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Sep 2018 14:34:41 -0700 (PDT)
Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com. [209.85.210.41])
        by smtp.gmail.com with ESMTPSA id 33-v6sm813911otw.29.2018.09.13.14.34.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 14:34:39 -0700 (PDT)
Received: by mail-ot1-f41.google.com with SMTP id v44-v6so2689675ote.13
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:34:39 -0700 (PDT)
MIME-Version: 1.0
References: <20180913211923.7696-1-timofey.titovets@synesis.ru> <93650ca3-dd72-ba84-49a3-7f383a0eb7e8@microsoft.com>
In-Reply-To: <93650ca3-dd72-ba84-49a3-7f383a0eb7e8@microsoft.com>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Fri, 14 Sep 2018 00:34:02 +0300
Message-ID: <CAGqmi77gN0f_3GP5A8zfnzaWj84ajkEmA8dXnpDHeOsj1tbaKQ@mail.gmail.com>
Subject: Re: [PATCH V7 0/2] KSM replace hash algo with xxhash
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel.Tatashin@microsoft.com
Cc: linux-mm@kvack.org, rppt@linux.vnet.ibm.com, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, Sioh Lee <solee@os.korea.ac.kr>

=D0=BF=D1=82, 14 =D1=81=D0=B5=D0=BD=D1=82. 2018 =D0=B3. =D0=B2 0:26, Pasha =
Tatashin <Pavel.Tatashin@microsoft.com>:
>
>
>
> On 9/13/18 5:19 PM, Timofey Titovets wrote:
> > From: Timofey Titovets <nefelim4ag@gmail.com>
> >
> > Currently used jhash are slow enough and replace it allow as to make KS=
M
> > less cpu hungry.
> >
> > About speed (in kernel):
> >         ksm: crc32c   hash() 12081 MB/s
> >         ksm: xxh64    hash()  8770 MB/s
> >         ksm: xxh32    hash()  4529 MB/s
> >         ksm: jhash2   hash()  1569 MB/s
> >
> > By sioh Lee tests (copy from other mail):
> > Test platform: openstack cloud platform (NEWTON version)
> > Experiment node: openstack based cloud compute node (CPU: xeon E5-2620 =
v3, memory 64gb)
> > VM: (2 VCPU, RAM 4GB, DISK 20GB) * 4
> > Linux kernel: 4.14 (latest version)
> > KSM setup - sleep_millisecs: 200ms, pages_to_scan: 200
> >
> > Experiment process
> > Firstly, we turn off KSM and launch 4 VMs.
> > Then we turn on the KSM and measure the checksum computation time until=
 full_scans become two.
> >
> > The experimental results (the experimental value is the average of the =
measured values)
> > crc32c_intel: 1084.10ns
> > crc32c (no hardware acceleration): 7012.51ns
> > xxhash32: 2227.75ns
> > xxhash64: 1413.16ns
> > jhash2: 5128.30ns
> >
> > In summary, the result shows that crc32c_intel has advantages over all
> > of the hash function used in the experiment. (decreased by 84.54% compa=
red to crc32c,
> > 78.86% compared to jhash2, 51.33% xxhash32, 23.28% compared to xxhash64=
)
> > the results are similar to those of Timofey.
> >
> > But,
> > use only xxhash for now, because for using crc32c,
> > cryptoapi must be initialized first - that require some
> > tricky solution to work good in all situations.
> >
> > So:
> >   - Fisrt patch implement compile time pickup of fastest implementation=
 of xxhash
> >     for target platform.
> >   - Second replace jhash2 with xxhash
> >
> > Thanks.
> >
> > CC: Andrea Arcangeli <aarcange@redhat.com>
> > CC: linux-mm@kvack.org
> > CC: kvm@vger.kernel.org
> > CC: leesioh <solee@os.korea.ac.kr>
> >
> > Timofey Titovets (2):
> >   xxHash: create arch dependent 32/64-bit xxhash()
> >   ksm: replace jhash2 with xxhash
> >
> >  include/linux/xxhash.h | 23 +++++++++++++
> >  mm/Kconfig             |  2 ++
> >  mm/ksm.c               | 93 ++++++++++++++++++++++++++++++++++++++++++=
+++++---
> >  3 files changed, 114 insertions(+), 4 deletions(-)
>
> This is wrong stat. ksm.c should not have any new lines at all.

Sorry, just copy-paste error when i rework patchset.
Must be:
 include/linux/xxhash.h | 23 +++++++++++++++++++++++
 mm/Kconfig             |  1 +
 mm/ksm.c               |  4 ++--

And i leave some useless new lines in second patch, i can drop them
byself and resend if that needed.

Thanks.
