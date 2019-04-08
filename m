Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 097EEC10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:11:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C178F20857
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 18:11:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ea72sH7G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C178F20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4461C6B026D; Mon,  8 Apr 2019 14:11:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F5386B026E; Mon,  8 Apr 2019 14:11:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30BED6B026F; Mon,  8 Apr 2019 14:11:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB1FF6B026D
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 14:11:30 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y17so10477966plr.15
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 11:11:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gCaZtAPIdoTmL89IrJBiBqajTRyKobTSTiuIO1WebTU=;
        b=DZi8+wtTWHUz1D8kZJ4e1u/6uO/jOBnNbzDiaBI3W/Qjp8OkPCMtuvuUS0U4I3sH8k
         CIQcKgS7XHjVoZdHnPnxII7qQCd7noKAXSoufEnXx5jVAqPM+3vF9kKMv8U6ggFgyQNm
         hYc9KJsnpJHJUm7XJtUJu6j5ybPEkaNIOlIf+iR4CztptxQ3bGy2cA0THjp2ZywaRUJg
         NO3ZctTaAnKknEAf03K4kVqtC/3dZVaUkuMwQJobZfQ2maRWFJPjk/rUikNswzvyv3jY
         YQHxTjHJysx/RNyYK6yHn0EhR08Sexhrl1sqQVq+RjZW0yf2mgZdR5/OFXL7UafEo20g
         AYVg==
X-Gm-Message-State: APjAAAW6Jog7S8Rk4CU5cU/M+KpRWS1H79pxByiF2qpXOijZjVkWHG3v
	3rN4vbztGVm17h1rSoLtcJDCoiJo8nyuENO7PUX4n0EFCmKrHFcL0pOf45YcTgn3Cbx2KqItYSa
	a4PkRInKiMDCedvZ7MD+Rs2cIUcRpTx5DgwyB6RaF7DCw8D1K6XA6wP663bJgDMVlKA==
X-Received: by 2002:a63:bd42:: with SMTP id d2mr29943158pgp.319.1554747090511;
        Mon, 08 Apr 2019 11:11:30 -0700 (PDT)
X-Received: by 2002:a63:bd42:: with SMTP id d2mr29943109pgp.319.1554747089840;
        Mon, 08 Apr 2019 11:11:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554747089; cv=none;
        d=google.com; s=arc-20160816;
        b=hAk5F9jRVYitbkG8e/Na6H1gPbuSB1cXlVHyuzcn3kSaR5y5N2Ar0REBLZS1teqcS/
         UHU1gRw1BV8VC1NMEXKZMcV0WonPeEcAE/KIiNRVM0porX/wcTXZs2/xFPp67DDsWI17
         PbbKQ9FOGgBapGT8WEHjOIungcWLvXzKx6yRm+8JLg/6Ea2yJkHYVFz5CXuRColYDUGK
         YOsR1f6q77BNMp5b+JvrUMubm6VfF0xQfYtN2/wmsiJCwA4rfYM78Pn6qHy9HQX9HqHo
         TBxs/tcInYm0Rk+U2TQag0cTj1EsM/5KT6+uKalich3r/0ZMO3ifpqPJVmrx/60qdFZ/
         ofzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gCaZtAPIdoTmL89IrJBiBqajTRyKobTSTiuIO1WebTU=;
        b=jbwwnVK7/ws5s4RchvQ8r0F1ibjQscfVA876gyNQhMnBAy84ci5BE7SGsnNPVU8yg1
         N2Ye9h0iReJY2yrdQpSu37K+iKTeyJ/T1eZN0o/GHwE6SLfOyexKVV3akz/0fTXtNrN7
         BHSl8hIfZW72ktRRJ/vPTU0/0etIskWis4oped7GU13jPSblQOXQiOcvE4yGgm3ASVUA
         qtT9c6YZOeeZGhm5SfF55BfZJXD9BYAsaQbLNib+YY17+iR3wR9Y9ekZBkvreWFENXTY
         TO3kBvlR1b6ExkE+8AaXB/FFrq+buu50TEeMyK0wr6beUhrK4GZnsghtCcq563V5I0gb
         Rv6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ea72sH7G;
       spf=pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ndesaulniers@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u23sor26700453pga.10.2019.04.08.11.11.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Apr 2019 11:11:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ea72sH7G;
       spf=pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ndesaulniers@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gCaZtAPIdoTmL89IrJBiBqajTRyKobTSTiuIO1WebTU=;
        b=Ea72sH7GwMqTkGBzJpLIvDEoenxfQLMSfNsp+dV90t0O4AWKpb+TGWDUCZz4smapDs
         7+HUVhdKUrRXCy2NN1mL5FIV07RduSMUKuVPvr3ipCFP4rAp9jNWjv1m2/pVq1/3yMDo
         mjTBhgRa3U6TGI6AVgsgsNPQQr5SVG+Z4ZgPwWkPgMIYw9IvOcV3YzcXdBTK+Oz8+PIM
         54+hKFeXxLfApDqzlDdHC84f4J4fhPNqfC+RY0bsCxw1onCp4+M+PsNKl+1HzCmTcbRJ
         Q+C8Hp/+e2FKwBLkr164WhtCN+dKBf4C3VTBK5xKESDBza8N97dw+XOjVZM4pm0uEI+g
         koRA==
X-Google-Smtp-Source: APXvYqw1KOyWweoVDabIoS6R1icouwYLPX8itpFgLUPIcRsok/618g9DEhJmI63u7Y0AOJf0LVl+etRwICdDCAgvW0c=
X-Received: by 2002:a63:465b:: with SMTP id v27mr30350154pgk.165.1554747088946;
 Mon, 08 Apr 2019 11:11:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190407022558.65489-1-trong@android.com> <CAKwvOdmBa-Ckk4wnp4OEPNdxeYSxEhzddykuWWGG1Wi6JEGDwA@mail.gmail.com>
In-Reply-To: <CAKwvOdmBa-Ckk4wnp4OEPNdxeYSxEhzddykuWWGG1Wi6JEGDwA@mail.gmail.com>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Mon, 8 Apr 2019 11:11:17 -0700
Message-ID: <CAKwvOdkCiS7bn68viW+TwDiwbvSq74zqc0B_xxBs-J0d5ieynQ@mail.gmail.com>
Subject: Re: [PATCH] module: add stub for within_module
To: Tri Vo <trong@android.com>, Jessica Yu <jeyu@kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>
Cc: Peter Oberparleiter <oberpar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Hackmann <ghackmann@android.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org, 
	kbuild test robot <lkp@intel.com>, LKML <linux-kernel@vger.kernel.org>, 
	Petri Gynther <pgynther@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 8, 2019 at 11:08 AM Nick Desaulniers
<ndesaulniers@google.com> wrote:
>
> On Sat, Apr 6, 2019 at 7:26 PM Tri Vo <trong@android.com> wrote:
> >
> > Provide a stub for within_module() when CONFIG_MODULES is not set. This
> > is needed to build CONFIG_GCOV_KERNEL.
> >
> > Fixes: 8c3d220cb6b5 ("gcov: clang support")
>
> The above commit got backed out of the -mm tree, due to the issue this
> patch addresses, so not sure it provides the correct context for the
> patch.  Maybe that line in the commit message should be dropped?

Maybe Jessica could drop that if/when applying?

>
> > Suggested-by: Matthew Wilcox <willy@infradead.org>
> > Reported-by: Randy Dunlap <rdunlap@infradead.org>
> > Reported-by: kbuild test robot <lkp@intel.com>
> > Link: https://marc.info/?l=linux-mm&m=155384681109231&w=2
> > Signed-off-by: Tri Vo <trong@android.com>
> > ---
> >  include/linux/module.h | 5 +++++
> >  1 file changed, 5 insertions(+)
> >
> > diff --git a/include/linux/module.h b/include/linux/module.h
> > index 5bf5dcd91009..47190ebb70bf 100644
> > --- a/include/linux/module.h
> > +++ b/include/linux/module.h
> > @@ -709,6 +709,11 @@ static inline bool is_module_text_address(unsigned long addr)
> >         return false;
> >  }
> >
> > +static inline bool within_module(unsigned long addr, const struct module *mod)
> > +{
> > +       return false;
> > +}
> > +
>
> Do folks think that similar stubs for within_module_core and
> within_module_init should be added, while we're here?
>

Otherwise, if the answer to the above is no,
Reviewed-by: Nick Desaulniers <ndesaulniers@google.com>

-- 
Thanks,
~Nick Desaulniers

