Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CB4EC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:27:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CB6921B25
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 19:27:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ohX8/5cR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CB6921B25
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF6978E0145; Mon, 11 Feb 2019 14:27:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C801C8E0134; Mon, 11 Feb 2019 14:27:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A83538E0145; Mon, 11 Feb 2019 14:27:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E55A8E0134
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:27:08 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v2so45769plg.6
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:27:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=+oM0/xXLOkqWUNTZclNstle1SN4HebVede/xP56WAdc=;
        b=mezKt8Bb/vb49Sbp3kFJFhyET3CZVYc95PFM2AvA7IlQYLu6FU0G8Pj/MblCm0Q/GB
         F2fx+0q85TikyUZAkXy3z6t9wr6lJyHOtVbz9qBkItld5HVSVlCKGht5LLhqqp/C1oTg
         6F7Jo9Hi/bKf+qJlVmqYTf/Bf1RqXGs2gYDdB6oy2MgWZx7D+mMQFJhPZlwS9BqbMA8j
         NuPh8bhvZIGTK4X/ramStD6hDswSSVFcWXCTp2BhyKnSpGlqoLdS8SSarwhphAb8OJIW
         ywyJPyNnNGlwFz7pLXN+PMHYERkV97Pq7XhT7FBJUTJUsUy8VEpfhoZM2V7vi3HdYpy0
         Qe7w==
X-Gm-Message-State: AHQUAuaiWKN+vWO5oc7ttp0P2Iy0h4m+abRa81kkysu0F8HjNNFLBMR2
	Fb0pqwTCpUn2JDYoZTsvVSE5XnW3FhAltXqVI+JKt1pN+Ry4sCTlmKfdbogZrkYSAJg0I+L4or7
	F7M3H34Reb8nWhyg43DFp63hXbGLqGfDR2/132i1fBasmyx/7ASvEWd7RiHSwaunBRFzE+q2aea
	K41/VuzITOth6D7WNXHhr3kfl/6Tk4pCIPW+oohlFe1PQdWVZK2JV8WDWz+5I507CHXc9M6XQ8B
	/jw8EHPdBQuQyXO2U1A06QmkBuIEB7EsBu5NU4/WQ8px6vJF5RoUV9K2Ep5W3Ma8LPj1tOMEjTS
	jzPC23AKgGCWJ+AW/JYWiCkWoI7pzS8+scTqO52Xph9LRkYum2aUNkXmPW4LfSIU5Fayrk9qUIT
	f
X-Received: by 2002:a62:1f97:: with SMTP id l23mr37887016pfj.13.1549913228081;
        Mon, 11 Feb 2019 11:27:08 -0800 (PST)
X-Received: by 2002:a62:1f97:: with SMTP id l23mr37886982pfj.13.1549913227457;
        Mon, 11 Feb 2019 11:27:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549913227; cv=none;
        d=google.com; s=arc-20160816;
        b=rC5JAlKr4aRbiaWqWAdk1N9bF0Verdvk4nhE6iQHg4kt7X4qdoq5Lb8FGadaa9/xrU
         0OpT4trK7sP0AkO4ZkmGS8mhGPw2mUVD/d/CDt0MRJgPwwL6qAYj+f4zap6Hmvy/33B8
         /Zy+QQMdQNa9TejQoQjzeaVrsogtWiI9uX5PnmAHtll9X9djW0NZAiVYjmmp6VKw6K2j
         2Rt+REts5m4o5ZckWh7rE4vT9lZMtC1eKlXMbMj3xBk4kHjBh/2kGtyIIJxfJMPFHeHo
         SkPHf1Jo2hbea2eSXnmIMmIc+MMROjMtDhoA/npZooq0cGYzCMiTEE8w5r+GZkIoJSET
         otYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=+oM0/xXLOkqWUNTZclNstle1SN4HebVede/xP56WAdc=;
        b=eCbylaQHKl38HLRorUIE778kLPetRzUd02nezH6Kb48QJRDsWvQE017eZ8sjkNMSBZ
         o/tunhBrPZlFFH5rXzns6qpqSvr/j7y6NBSwhSmzXvHMJ6ZwgCCxwjL+pqnUuo4O2THq
         so6EhOtDoB1fggoGqnQ4N8EXXWMKXUI1hiPcMkxutKKnjz11wAltYJoYJ6JaGbH662yF
         F438PM/Wb5/k+N5pnZXXQyVyvv4ZVoE/XB0WeGI4NSs0HaWDs1b1UAHF3E3THE5xJHAF
         DC4griyJc78CZCRJkk/04qKhfpRJRmDJz+pkGajBCKMx4n8puznC1+QIL8dAdg+9kC4A
         aBKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ohX8/5cR";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z13sor2370059pgp.62.2019.02.11.11.27.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 11:27:07 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ohX8/5cR";
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=+oM0/xXLOkqWUNTZclNstle1SN4HebVede/xP56WAdc=;
        b=ohX8/5cRhRlFAEE+pStLv5HD83z/gPPjShpexmPKbkoB+4M+/8bvC+G12H1oNlpZ4X
         Xr5D1wcj9+8Wmc2PtwVleNcbPFyVVHe89XLTO1BOtdyivFyrTTkX3DR3H5h6E22yTOgb
         ElX9TKuHZYNDKqOvh8bAwXU+fMAy71Gtqml5Hix/FlfaI4HBLytzliJCCy1LV5oBYts4
         GqKpuRQd/1xGtE1LdEe51/WW9xgqMad5ur5z9i6SkkwtdoSgnZ8fhJv4keIPyJHg62bt
         6Z2/yQgYt7iGgy8NUaS/c8ZAVR+T3R+iTCfjv3rWEefhFf47LKGoyB3uA3KlxFENE5g9
         Vikg==
X-Google-Smtp-Source: AHgI3IaY1AiMYebkmcDfbYYok1NODcbe/RnHFWN6Al9Fn2I2kEnfJveqTXvy5uGklYvEz/WRKUL66w==
X-Received: by 2002:a63:4658:: with SMTP id v24mr34547801pgk.114.1549913226955;
        Mon, 11 Feb 2019 11:27:06 -0800 (PST)
Received: from [10.33.115.182] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id a187sm9887508pfb.61.2019.02.11.11.27.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 11:27:05 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules
 loading
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20190211191059.GR19618@zn.tnic>
Date: Mon, 11 Feb 2019 11:27:03 -0800
Cc: Rick Edgecombe <rick.p.edgecombe@intel.com>,
 Andy Lutomirski <luto@kernel.org>,
 Ingo Molnar <mingo@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>,
 X86 ML <x86@kernel.org>,
 "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Peter Zijlstra <peterz@infradead.org>,
 Damian Tometzki <linux_dti@icloud.com>,
 linux-integrity <linux-integrity@vger.kernel.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>,
 Will Deacon <will.deacon@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Kristen Carlson Accardi <kristen@linux.intel.com>,
 "Dock, Deneen T" <deneen.t.dock@intel.com>,
 Kees Cook <keescook@chromium.org>,
 Dave Hansen <dave.hansen@intel.com>,
 Masami Hiramatsu <mhiramat@kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic>
 <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic>
 <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
 <20190211191059.GR19618@zn.tnic>
To: Borislav Petkov <bp@alien8.de>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 11, 2019, at 11:10 AM, Borislav Petkov <bp@alien8.de> wrote:
>=20
> On Mon, Feb 11, 2019 at 11:09:25AM -0800, Nadav Amit wrote:
>> It is just that I find the use of static_cpu_has()/boot_cpu_has() to =
be very
>> inconsistent. I doubt that show_cpuinfo_misc(), =
copy_fpstate_to_sigframe(),
>> or i915_memcpy_init_early() that use static_cpu_has() are any hotter =
than
>> text_poke_early().
>=20
> Would some beefing of the comment over it help?

Is there any comment over static_cpu_has()? ;-)

Anyhow, obviously a comment would be useful.

