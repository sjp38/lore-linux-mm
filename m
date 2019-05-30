Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DDACC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 01:36:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CF06243D7
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 01:36:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CF06243D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C1596B0010; Wed, 29 May 2019 21:36:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 871366B026D; Wed, 29 May 2019 21:36:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75FE46B026E; Wed, 29 May 2019 21:36:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 565626B0010
	for <linux-mm@kvack.org>; Wed, 29 May 2019 21:36:37 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id n10so3740306ita.2
        for <linux-mm@kvack.org>; Wed, 29 May 2019 18:36:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=P23E/eENo+9ZN8VV6t21D/esBQLZ+3eAEvTlZwBMDbI=;
        b=aOEi3uHOaFZlDmpxwbVj6zvKVkJVVujSf0G61FSPGZJ0Hn81fqTY8NyS9RFgeYRJ8h
         ZMfnVOy3GwpwHw7wYGM9RYYd5JIgAR4oABbg6H0LVR+g/8tCQsqxz0xS8A6yWy3Mzzep
         VDdFDGNJVOEWmjtHTDAHee2Y28CLVJOT3eDiHeuh9euU4Tp5Hdu5GKPkvQVH6adt5oEF
         NQU93HIKrOJyz7udVPh/J/dxsOLmaq4eu+zEGroKNnYJ+AOI8ALuVrvlNbikzp2mwKCs
         T47GVNxpSWqSwNU9WPXswcLmdJcg5T0/TaaDzOfFCblsEYKxqp56wTnchZklbL5LaJuw
         e4VQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAVSYPaLotz0lhDAyt1sb01ASTnpu4xs7/LMLbwbyB54VqZWH2G2
	PU9HSBcGyJHNxzgp9/A2Qnu/lxREu3lk+TVqA5VcmCBRvYnu4d6s9qBi0DA76jJzPtXiWQGI9K+
	dQFkBSqKMFW4063weX7ByLga5nJFWOwUdGb74Za/BLGis2iLdGf0C7RdqppHrpUDr+A==
X-Received: by 2002:a05:660c:64f:: with SMTP id y15mr1100315itk.180.1559180197046;
        Wed, 29 May 2019 18:36:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfpbtWNurPcJcykKvXgBrj+pXDyCcsw4UqZJVqtxO6luVMsVrZwNr155x/0FedKagFp0J+
X-Received: by 2002:a05:660c:64f:: with SMTP id y15mr1100280itk.180.1559180196212;
        Wed, 29 May 2019 18:36:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559180196; cv=none;
        d=google.com; s=arc-20160816;
        b=QV4rRskWAs2ZCDnlgUvDkwLlnZ00qUtF89IYjPVRvrRa/KGQdXq1YIemN6kbez02Pd
         3TdyeUVHxAj0sSTm0vZM6+Kh0EFqeUAA+0lOZOiLb3mR4kh7QXLWlxzChTbrk6DseJ17
         qNn06oP7wjsqowJtzhiaWbf34Ik9qD8oVcimK1BjzEiA6VBFyHmH5ticiGHDIg+CAM6J
         9lfcgqvt/ogwM/QW+Qd3P5y2OOqY751Shv3TVpNGBXl05iyXkmbrTRkbIWYg8FayYIMz
         kFvjacQ16WBdWDOFb5GneTnqbIIXtoiG/grZLsnn5nEM8ZDGdcyV4pNAChpAqX0AVB9A
         Dg9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=P23E/eENo+9ZN8VV6t21D/esBQLZ+3eAEvTlZwBMDbI=;
        b=c0TxSjHhH0gqs8S/+z6VYlNv2dLULge3vY/2wO3/CF7P1mXrOPQF5Hmi2eg4LSdTwX
         S6tqBwlLldfYvBXJrmhKimIWSLdsqVH2CHQLz97KkxawRBQhlQSZ5BWh+zCDsb5KrHHS
         cwRJOGpBuFv/X2OEdZET7XjuCZK7zlOGB5SNYW6Zkb6QNaKuTkR0jtlyv3tShskRuylZ
         HfW8gd7EDaZivjbPID/mT/vn+UCPC27oPboEuzLa5km4f+O2baDriqsRzGxQzLwaJdaI
         0aW91PdyqYXIAM9G09bBAntZSQUcoT0QL1A9+xhup474VzW8lkBiirTEfKAJJgco3zQB
         76qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id m4si698659ioj.16.2019.05.29.18.36.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 18:36:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x4U1aBLY004110
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 30 May 2019 10:36:11 +0900
Received: from mailsv02.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x4U1aB2E021407;
	Thu, 30 May 2019 10:36:11 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x4U1V0M6011627;
	Thu, 30 May 2019 10:36:11 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.151] [10.38.151.151]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-5509030; Thu, 30 May 2019 10:35:45 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC23GP.gisp.nec.co.jp ([10.38.151.151]) with mapi id 14.03.0319.002; Thu,
 30 May 2019 10:35:44 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>,
        "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
        "Chen, Jerry T" <jerry.t.chen@intel.com>,
        "Zhuo, Qiuxu" <qiuxu.zhuo@intel.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v1] mm: hugetlb: soft-offline: fix wrong return value of
 soft offline
Thread-Topic: [PATCH v1] mm: hugetlb: soft-offline: fix wrong return value
 of soft offline
Thread-Index: AQHVFFJeyxW0HZW72U2AA7NEa5OFu6aB3awAgABy1IA=
Date: Thu, 30 May 2019 01:35:44 +0000
Message-ID: <20190530013549.GA28893@hori.linux.bs1.fc.nec.co.jp>
References: <1558937200-18544-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <81a37f9c-4a85-c18d-b882-f361c4998d45@oracle.com>
In-Reply-To: <81a37f9c-4a85-c18d-b882-f361c4998d45@oracle.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <A86EE488D3DDAC4DB8641398482BD783@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000012, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mike,

On Wed, May 29, 2019 at 11:44:50AM -0700, Mike Kravetz wrote:
> On 5/26/19 11:06 PM, Naoya Horiguchi wrote:
> > Soft offline events for hugetlb pages return -EBUSY when page migration
> > succeeded and dissolve_free_huge_page() failed, which can happen when
> > there're surplus hugepages. We should judge pass/fail of soft offline b=
y
> > checking whether the raw error page was finally contained or not (i.e.
> > the result of set_hwpoison_free_buddy_page()), so this behavior is wron=
g.
> >=20
> > This problem was introduced by the following change of commit 6bc9b5643=
3b76
> > ("mm: fix race on soft-offlining"):
> >=20
> >                     if (ret > 0)
> >                             ret =3D -EIO;
> >             } else {
> >     -               if (PageHuge(page))
> >     -                       dissolve_free_huge_page(page);
> >     +               /*
> >     +                * We set PG_hwpoison only when the migration sourc=
e hugepage
> >     +                * was successfully dissolved, because otherwise hw=
poisoned
> >     +                * hugepage remains on free hugepage list, then use=
rspace will
> >     +                * find it as SIGBUS by allocation failure. That's =
not expected
> >     +                * in soft-offlining.
> >     +                */
> >     +               ret =3D dissolve_free_huge_page(page);
> >     +               if (!ret) {
> >     +                       if (set_hwpoison_free_buddy_page(page))
> >     +                               num_poisoned_pages_inc();
> >     +               }
> >             }
> >             return ret;
> >      }
> >=20
> > , so a simple fix is to restore the PageHuge precheck, but my code
> > reading shows that we already have PageHuge check in
> > dissolve_free_huge_page() with hugetlb_lock, which is better place to
> > check it.  And currently dissolve_free_huge_page() returns -EBUSY for
> > !PageHuge but that's simply wrong because that that case should be
> > considered as success (meaning that "the given hugetlb was already
> > dissolved.")
>=20
> Hello Naoya,
>=20
> I am having a little trouble understanding the situation.  The code above=
 is
> in the routine soft_offline_huge_page, and occurs immediately after a cal=
l to
> migrate_pages() with 'page' being the only on the list of pages to be mig=
rated.
> In addition, since we are in soft_offline_huge_page, we know that page is
> a huge page (PageHuge) before the call to migrate_pages.
>=20
> IIUC, the issue is that the migrate_pages call results in 'page' being
> dissolved into regular base pages.  Therefore, the call to
> dissolve_free_huge_page returns -EBUSY and we never end up setting PageHW=
Poison
> on the (base) page which had the error.
>=20
> It seems that for the original page to be dissolved, it must go through t=
he
> free_huge_page routine.  Once that happens, it is possible for the (disso=
lved)
> pages to be allocated again.  Is that just a known race, or am I missing
> something?

No, your understanding is right.  I found that the last (and most important=
)
part of patch description ("this behavior is wrong") might be wrong.
Sorry about that and let me correct myself:

  - before commit 6bc9b56433b76, the return value of soft offline is the
    return of migrate_page(). dissolve_free_huge_page()'s return value is
    ignored.

  - after commit 6bc9b56433b76 soft_offline_huge_page() returns success
    only dissolve_free_huge_page() returns success.

This change is *mainly OK* (meaning nothing is broken), but there still
remains the room of improvement, that is, even in "dissolved from
free_huge_page()" case, we can try to call set_hwpoison_free_buddy_page() t=
o
contain the 4kB error page, but we don't try it now because
dissolve_free_huge_page() return -EBUSY for !PageHuge case.

>=20
> > This change affects other callers of dissolve_free_huge_page(),
> > which are also cleaned up by this patch.
>=20
> It may just be me, but I am having a hard time separating the fix for thi=
s
> issue from the change to the dissolve_free_huge_page routine.  Would it b=
e
> more clear or possible to create separate patches for these?

Yes, the change is actually an 'improvement' purely related to hugetlb,
and seems not a 'bug fix'. So I'll update the description.
Maybe no need to separate to patches.

Thanks,
Naoya Horiguchi=

