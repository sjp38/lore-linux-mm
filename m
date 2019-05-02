Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5552C04AAA
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:33:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9407920652
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:33:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9407920652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 478A26B0007; Thu,  2 May 2019 12:33:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 428476B0008; Thu,  2 May 2019 12:33:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A3256B000A; Thu,  2 May 2019 12:33:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DFD086B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 12:33:26 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d20so1497245pls.15
        for <linux-mm@kvack.org>; Thu, 02 May 2019 09:33:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vajMcs4PWAXHtSOiyQ0yTUvNz0gHpMKHR6CyxPytvwM=;
        b=KyL6m9QdUGgnQBzZRc0j2cJl/NU7/+Zdg4in0VKEuW2s/J23Sx6e2Qu6+Sl5Iev+pl
         b7n9Mdxs9L+qIRD4XUY2CFsYGzY5ZkIn6ssR0UM1ulP9QXuhl00AiINvTEH3ipB5RNJu
         qXljIQAm9FIC6JfmZPjtTYoWUGLeQX8TZ4saRPwdahQxS/ApDUkQhKSIvdHhLOrePF2q
         6EkcRVb5lokG8aXM2mgQl/paNngKeddFAUsRmvnvtqqM5LG9cUsPfEUN22ND2jsQut6i
         aZNNxoJzzOwwtaeswcC6TQ0J13J69NN7/Q8GruZLAfVL+IzExrm3+yWrQxBUmqYw4RHl
         5knQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXMAYnmFsiDBpoxmXVXsgRXX/IfEhomDKdFIyYTfJ1P21Isf7II
	o4GeffqZIiqsePS7wovtal7dl4ncvBi92ZT0JY6fpUhpu+U3ModGGEAnSlV61yFgPntQA//fy4c
	N6OlpJFSs5fvoWJykinsgasOmDndmkXhqyQNpejhEN+XLL8BYjrd3YQCsIRp+N9WRSg==
X-Received: by 2002:a63:1b15:: with SMTP id b21mr4845307pgb.364.1556814806557;
        Thu, 02 May 2019 09:33:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxn1r70Mfg8ij/U5P7fMZBjKVSprK2P5pxXbe1aLNFdYtEOlpJ73j2WD0YqqjiCXCzQQubS
X-Received: by 2002:a63:1b15:: with SMTP id b21mr4845246pgb.364.1556814805839;
        Thu, 02 May 2019 09:33:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556814805; cv=none;
        d=google.com; s=arc-20160816;
        b=ywQhK4niEh/ZiJNTcyu31KJzH9dMm7B2G25ELErkmTIFwVKwOPkOZc+YvHIUlLU9Ih
         4cXkBq/OBXhlQjl2OsGgZ7+bdxNUDvAlZsJUqYTnKV6+lktASq8mjMOy1xTDQJ5CMUp3
         bY31qL6l/kCExGIRrMx5qxW4AE8cHJAe0fMp/hLMStp/1nC0rdNHusvTgb+/jjl3Rlol
         W6MiN+fDxjiBps54OTbB75Ot3Z9GI+AmPF33UmKZVoRs/YqyKGWCYxumgFpSPI73t8fg
         G8KLDefgMsdKHmmQ9U1O/qs0QgcnVEV3ZXATaEjscnX/ze9EU9tOC+yA06uj5ojY234C
         1F3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=vajMcs4PWAXHtSOiyQ0yTUvNz0gHpMKHR6CyxPytvwM=;
        b=L+42PKcuuX+959ja5R2QVoFCnXhFzXMp6eX9Hfkaf35PWip0lUm7V3wSkqk9geevim
         Rx6s8c2yBH3RmKeY42wVJ+dGpqcDPbcEJaIWCV1nkAGMtD68sjra68AhbPdYwXMMu5Bv
         vEyQjt2UA0A8Drkox0PEj7P4ZJ4oLyc/UCCoELuPTxs2z9y6ETLEC3aXNVsGwvXfJXw0
         EZEvZXQKGg1/zJvKFx6aLDZ86ak3mEeGtVNntuoTIXRvps3BPiT+6c5UnQYCzJiwqVJS
         cIGq+UQguwehOvMOPru8yHXeF94Xq81REjIjzxq0Ex7g44EgILkui+MYWCJLiopxe6IG
         kd9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id p12si17492192pgn.431.2019.05.02.09.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 09:33:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 May 2019 09:33:25 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,422,1549958400"; 
   d="scan'208";a="296427717"
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga004.jf.intel.com with ESMTP; 02 May 2019 09:33:23 -0700
Message-ID: <91611b9e159799bbf603b65cf7bb6b37dd81b075.camel@intel.com>
Subject: Re: [PATCH] binfmt_elf: Extract .note.gnu.property from an ELF file
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: Dave Martin <Dave.Martin@arm.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-mm@kvack.org,  linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>,
 Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Eugene Syromiatnikov
 <esyr@redhat.com>,  Florian Weimer <fweimer@redhat.com>, "H.J. Lu"
 <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet
 <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz
 <mike.kravetz@oracle.com>,  Nadav Amit <nadav.amit@gmail.com>, Oleg
 Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra
 <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V.
 Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue
 <vedvyas.shanbhogue@intel.com>,  Szabolcs Nagy <szabolcs.nagy@arm.com>,
 libc-alpha@sourceware.org
Date: Thu, 02 May 2019 09:25:56 -0700
In-Reply-To: <20190502161424.GQ3567@e103592.cambridge.arm.com>
References: <20190501211217.5039-1-yu-cheng.yu@intel.com>
	 <20190502111003.GO3567@e103592.cambridge.arm.com>
	 <5b2c6cee345e00182e97842ae90c02cdcd830135.camel@intel.com>
	 <20190502161424.GQ3567@e103592.cambridge.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.1-2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-05-02 at 17:14 +0100, Dave Martin wrote:
> On Thu, May 02, 2019 at 08:47:06AM -0700, Yu-cheng Yu wrote:
> > On Thu, 2019-05-02 at 12:10 +0100, Dave Martin wrote:
> > > On Wed, May 01, 2019 at 02:12:17PM -0700, Yu-cheng Yu wrote:
> > > > An ELF file's .note.gnu.property indicates features the executable file
> > > > can support.  For example, the property GNU_PROPERTY_X86_FEATURE_1_AND
> > > > indicates the file supports GNU_PROPERTY_X86_FEATURE_1_IBT and/or
> > > > GNU_PROPERTY_X86_FEATURE_1_SHSTK.
> > 
> > [...]
> > > A couple of questions before I look in more detail:
> > > 
> > > 1) Can we rely on PT_GNU_PROPERTY being present in the phdrs to describe
> > > the NT_GNU_PROPERTY_TYPE_0 note?  If so, we can avoid trying to parse
> > > irrelevant PT_NOTE segments.
> > 
> > Some older linkers can create multiples of NT_GNU_PROPERTY_TYPE_0.  The code
> > scans all PT_NOTE segments to ensure there is only one
> > NT_GNU_PROPERTY_TYPE_0. 
> > If there are multiples, then all are considered invalid.
> 
> I'm concerned that in the arm64 case we would waste some effort by
> scanning multiple notes.
> 
> Could we do something like iterating over the phdrs, and if we find
> exactly one PT_GNU_PROPERTY then use that, else fall back to scanning
> all PT_NOTEs?

That makes sense to me, but the concern is that we don't know the
PT_GNU_PROPERTY the only one.  This probably needs to be discussed with more
people.

> > > 2) Are there standard types for things like the program property header?
> > > If not, can we add something in elf.h?  We should try to coordinate with
> > > libc on that.  Something like
> > > 
> > > typedef __u32 Elf_Word;
> > > 
> > > typedef struct {
> > > 	Elf_Word pr_type;
> > > 	Elf_Word pr_datasz;
> > > } Elf_Gnu_Prophdr;
> > > 
> > > (i.e., just the header part from [1], with a more specific name -- which
> > > I just made up).
> > 
> > Yes, I will fix that.
> > 
> > [...]
> > > 3) It looks like we have to go and re-parse all the notes for every
> > > property requested by the arch code.
> > 
> > As explained above, it is necessary to scan all PT_NOTE segments.  But there
> > should be only one NT_GNU_PROPERTY_TYPE_0 in an ELF file.  Once that is
> > found,
> > perhaps we can store it somewhere, or call into the arch code as you
> > mentioned
> > below.  I will look into that.
> 
> Just to get something working on arm64, I'm working on some hacks that
> move things around a bit -- I'll post when I have something.
> 
> Did you have any view on my other point, below?

That should work.  I will also make some changes for that.

> 
> Cheers
> ---Dave
> 
> > > For now there is only one property requested anyway, so this is probably
> > > not too bad.  But could we flip things around so that we have some
> > > CONFIG_ARCH_WANTS_ELF_GNU_PROPERTY (say), and have the ELF core code
> > > call into the arch backend for each property found?
> > > 
> > > The arch could provide some hook
> > > 
> > > 	int arch_elf_has_gnu_property(const Elf_Gnu_Prophdr *prop,
> > > 					const void *data);
> > > 
> > > to consume the properties as they are found.
> > > 
> > > This would effectively replace the arch_setup_property() hook you
> > > currently have.
> > > 
> > > Cheers
> > > ---Dave
> > > 
> > > [1] https://github.com/hjl-tools/linux-abi/wiki/Linux-Extensions-to-gABI

