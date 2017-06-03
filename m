Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF356B0292
	for <linux-mm@kvack.org>; Sat,  3 Jun 2017 06:35:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 139so19202347wmf.5
        for <linux-mm@kvack.org>; Sat, 03 Jun 2017 03:35:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i2si26317469eda.252.2017.06.03.03.35.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jun 2017 03:35:06 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v53AYTiF109883
	for <linux-mm@kvack.org>; Sat, 3 Jun 2017 06:35:05 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2autdnhuf8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 03 Jun 2017 06:35:04 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sat, 3 Jun 2017 11:35:03 +0100
Date: Sat, 03 Jun 2017 13:34:52 +0300
In-Reply-To: <f9e8a159-7a25-6813-f909-11c4ae58adf3@suse.cz>
References: <1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com> <20170602125059.66209870607085b84c257593@linux-foundation.org> <8a810c81-6a72-2af0-a450-6f03c71d8cca@suse.cz> <20170602134038.13728cb77678ae1a7d7128a4@linux-foundation.org> <f9e8a159-7a25-6813-f909-11c4ae58adf3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Subject: Re: [PATCH] mm: make PR_SET_THP_DISABLE immediately active
From: Mike Rapoprt <rppt@linux.vnet.ibm.com>
Message-Id: <CAAB5A6A-D7A1-4C06-9A07-D7EF56278EE5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux API <linux-api@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On June 2, 2017 11:55:12 PM GMT+03:00, Vlastimil Babka <vbabka@suse=2Ecz> =
wrote:
>On 06/02/2017 10:40 PM, Andrew Morton wrote:
>> On Fri, 2 Jun 2017 22:31:47 +0200 Vlastimil Babka <vbabka@suse=2Ecz>
>wrote:
>>>> Perhaps we should be adding new prctl modes to select this new
>>>> behaviour and leave the existing PR_SET_THP_DISABLE behaviour
>as-is?
>>>
>>> I think we can reasonably assume that most users of the prctl do
>just
>>> the fork() & exec() thing, so they will be unaffected=2E
>>=20
>> That sounds optimistic=2E  Perhaps people are using the current
>behaviour
>> to set on particular mapping to MMF_DISABLE_THP, with
>>=20
>> 	prctl(PR_SET_THP_DISABLE)
>> 	mmap()
>> 	prctl(PR_CLR_THP_DISABLE)
>>=20
>> ?
>>=20
>> Seems a reasonable thing to do=2E
>
>Using madvise(MADV_NOHUGEPAGE) seems reasonabler to me, with the same
>effect=2E And it's older (2=2E6=2E38)=2E
>
>> But who knows - people do all sorts of
>> inventive things=2E
>
>Yeah :( but we can hope they don't even know that the prctl currently
>behaves they way it does - man page doesn't suggest it would, and most
>of us in this thread found it surprising=2E
>
>>> And as usual, if
>>> somebody does complain in the end, we revert and try the other way?
>>=20
>> But by then it's too late - the new behaviour will be out in the
>field=2E
>
>Revert in stable then?
>But I don't think this patch should go to stable=2E I understand right
>that CRIU will switch to the UFFDIO_COPY approach and doesn't need the
>prctl change/new madvise anymore?

Yes, we are going to use UFFDIO_COPY=2E We still might want to have contro=
l over THP in the future without changing per-VMA flags, though=2E

--=20
Sincerely yours,
Mike=2E

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
