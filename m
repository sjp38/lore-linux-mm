Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 297EDC468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:29:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA860208C3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:29:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="lg7aoPtq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA860208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 859096B000A; Fri,  7 Jun 2019 14:29:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E2646B000C; Fri,  7 Jun 2019 14:29:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65B916B000E; Fri,  7 Jun 2019 14:29:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5AA6B000A
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 14:29:55 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id v62so1974396pgb.0
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 11:29:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=iPuLGydOavIYd0+wELWGKM4fGfit4THzqki57BPPV4U=;
        b=O//Odod3YIyg+SorkyLujOPlgHNnebXSa8befGJQnKcy1yNwnSN3tkdIusq5AwMBrN
         vaQ3Gobc8ko0zVdICFCNHF7f1SF7NzimqBDS9Am5WCZ8DeqJEpFoPBm/LKuwlvJViEG3
         7rrSn0OkyGL6dIT5GCURxGA2toNdc/3GZ2jTuhL1y1vSL4HyK/0fdg/OcP2cChY4KJt2
         ScTJ6Yo4b1/tFkXFkSCTjj0nIKfsSKIXAzxANYYkqqLVNatw0gOx85oXSKHhTQnVWqe8
         yiYu5ooNk5J21t9Yh2+7G7ea7xseQXmXxlDfDRSSaY4LObX4x7axNLVJDM6ePJ2IM5by
         BeMg==
X-Gm-Message-State: APjAAAUa+KljtIP0jGCj7RKBOBjiwp+gX1T3gKLjxkKIejlrBRWo56pj
	ZDlzTafzojMceXVzHKIy1JzpbSr7peFvqxd0kmoFukzqIDSo3/0tp5KP+EE04wqCY3VhqSrEgTi
	1zyrRP8A5E61nDzpRePS+jNg5TPDUvHrrXK1QYLkuqxF28iDSOOJ01yzP3EbVO7aRgg==
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr55632332pld.271.1559932194764;
        Fri, 07 Jun 2019 11:29:54 -0700 (PDT)
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr55632256pld.271.1559932194046;
        Fri, 07 Jun 2019 11:29:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559932194; cv=none;
        d=google.com; s=arc-20160816;
        b=vKHHH6Q+hOF9lFxRkYIcwnzu9wja3UUTiubibTtfLV9AM0fjrJpKG6jh2nXnvllfDH
         EJIROKHZVPAEa73B3bCJlEZNTM2EblAowfkoo8FP0pACu8+fsjlMwlyAmEWnC2KqAaY6
         XCCp6dc1Qy/VJhSkc4YuBt0Zkhgw5BYP5gCep6EkThs0RkOtQDyLtNaL8q6/yUPw99DF
         FzJdanpqe3Wph1VzytxVXY7Lmt7BTwcglCjy/OJ6pUDzHE0jd16wZg23zM9YmsgsolVr
         Il7TpVJHrCkpFi1uqUW5oIowAuVrHGTbS3ywGRHTEWYpqrTLng4tVH95MhK74SSKGTTX
         6uNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=iPuLGydOavIYd0+wELWGKM4fGfit4THzqki57BPPV4U=;
        b=E9ki5JqKKMShL3gxxJZj0/Api6Ypk9lLoxjnOhByU5OMGXDThfWv1MsGC1vXYhmWKC
         lGJln6zCT7ZN7Q7LAI5SybfnI3ktHyahF998Rr2Hd6WFxK7TjrzKkEVrXaKhxoX/YuOx
         a3br834jccdU7VOKi0XJtqBGULYJSNWtx2j4aTk/XPamwVIFEKzoREeVEl+Fw+1u6jlg
         ymoysH4tzd68/lqTz85CIWQf4G8hZHkGTTu2gzT1OmMHcaVLl/i+P1/eZ2TROzAg67JO
         QU/dTmDHcG1WLdd/jFJEcqsJZEsbme/SwAie7bfa8xzmLHLjHzPD8djBahGD7cDOs7Er
         W3tQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=lg7aoPtq;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f38sor3474800pjg.13.2019.06.07.11.29.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 11:29:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=lg7aoPtq;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=iPuLGydOavIYd0+wELWGKM4fGfit4THzqki57BPPV4U=;
        b=lg7aoPtqp9Hb92R8oH6RAUOmupz6mJN7bNCFgiizfRjRxEHrih+BHeECksF/ofFo+d
         Gca1+QdVmTh/8SL4feJ1/2529qt+bY7R4DNbVPsSnXMwFEHbMKCAJeDfe5oyP784L847
         zI5icl4CBjsxAnmXBxZOgOJkC67xHD5guteumdR+SzGRAqs+zcoxpcGYvNXrcj0Kg/KR
         t0RpPZcx8kewURUpcoeCa6Q9p/SCpI/AeBa72cgZYDOsIbMIEQuIVI08rJY/7o80AFHB
         IEXTdyNxMrTM0/BtMGFhILWDJk6/oALcRhTA/U9DE1OnXw5xwpv1vVb7lzhXy22LvO+I
         cMvw==
X-Google-Smtp-Source: APXvYqzvhAzsKyCtFsLkEsrBKKf0SyVY50xd6UzRSykGMq36ETMdxZgn9Qk9tfswhyyV5VdxrKxgCg==
X-Received: by 2002:a17:90a:cb0a:: with SMTP id z10mr7463663pjt.101.1559932193640;
        Fri, 07 Jun 2019 11:29:53 -0700 (PDT)
Received: from ?IPv6:2600:1012:b044:6f30:60ea:7662:8055:2cca? ([2600:1012:b044:6f30:60ea:7662:8055:2cca])
        by smtp.gmail.com with ESMTPSA id 139sm3061757pfw.152.2019.06.07.11.29.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 11:29:52 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16F203)
In-Reply-To: <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
Date: Fri, 7 Jun 2019 11:29:50 -0700
Cc: Peter Zijlstra <peterz@infradead.org>,
 Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org,
 "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>,
 Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>,
 Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>,
 Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>,
 Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>,
 Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
 Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-4-yu-cheng.yu@intel.com> <20190607080832.GT3419@hirez.programming.kicks-ass.net> <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com> <20190607174336.GM3436@hirez.programming.kicks-ass.net> <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jun 7, 2019, at 10:59 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
>> On 6/7/19 10:43 AM, Peter Zijlstra wrote:
>> I've no idea what the kernel should do; since you failed to answer the
>> question what happens when you point this to garbage.
>>=20
>> Does it then fault or what?
>=20
> Yeah, I think you'll fault with a rather mysterious CR2 value since
> you'll go look at the instruction that faulted and not see any
> references to the CR2 value.
>=20
> I think this new MSR probably needs to get included in oops output when
> CET is enabled.

This shouldn=E2=80=99t be able to OOPS because it only happens at CPL 3, rig=
ht?  We should put it into core dumps, though.

>=20
> Why don't we require that a VMA be in place for the entire bitmap?
> Don't we need a "get" prctl function too in case something like a JIT is
> running and needs to find the location of this bitmap to set bits itself?
>=20
> Or, do we just go whole-hog and have the kernel manage the bitmap
> itself. Our interface here could be:
>=20
>    prctl(PR_MARK_CODE_AS_LEGACY, start, size);
>=20
> and then have the kernel allocate and set the bitmap for those code
> locations.

Given that the format depends on the VA size, this might be a good idea.  I b=
et we can reuse the special mapping infrastructure for this =E2=80=94 the VM=
A could
be a MAP_PRIVATE special mapping named [cet_legacy_bitmap] or similar, and w=
e can even make special rules to core dump it intelligently if needed.  And w=
e can make mremap() on it work correctly if anyone (CRIU?) cares.

Hmm.  Can we be creative and skip populating it with zeros?  The CPU should o=
nly ever touch a page if we miss an ENDBR on it, so, in normal operation, we=
 don=E2=80=99t need anything to be there.  We could try to prevent anyone fr=
om *reading* it outside of ENDBR tracking if we want to avoid people acciden=
tally wasting lots of memory by forcing it to be fully populated when the re=
ad it.

The one downside is this forces it to be per-mm, but that seems like a gener=
ally reasonable model anyway.

This also gives us an excellent opportunity to make it read-only as seen fro=
m userspace to prevent exploits from just poking it full of ones before redi=
recting execution.=

