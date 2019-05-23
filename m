Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05155C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 11:49:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABFA820879
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 11:49:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BY/HQXW/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABFA820879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 165626B000A; Thu, 23 May 2019 07:49:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EEAB6B000C; Thu, 23 May 2019 07:49:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5BCC6B000D; Thu, 23 May 2019 07:49:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 82E596B000A
	for <linux-mm@kvack.org>; Thu, 23 May 2019 07:49:55 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id m2so1205647ljj.13
        for <linux-mm@kvack.org>; Thu, 23 May 2019 04:49:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=YevW+X+2+POPi7PMf63t0Xk4zVo6kPahAFQzxSKuB6A=;
        b=HzaOWKPScjsLxrAwmz/AtAhTM0s43F8YEFRDqaWdUuzS7ZEcI44BCKCO8tqcfeVWOC
         mxRk7nNvhFxwp/d+wjDpQshzH0J9emkC43bT61PcQFI+gwRp+XI8ypS6r/mUuhQ5SBW2
         Ta+eGhX/OMt9Efko9I3/P7vZ2Vgtny9aYd5DCf+lFqXr7DEKAKUFRNNVKpty/96DU9xR
         rWoiLAc5frsza2WIvKoJFtNNsiaWEb/YmHQE6QRWeFYL+HCbYIQiDHgBTPH+UjCmAQzB
         RWRBqLqWxK/Aue2J/Djnvgf2fcnUyYeBcl2PJ/cEQgE5ChPnrAYTDeQ3xwyb+LPcn/W3
         AreA==
X-Gm-Message-State: APjAAAXEcFuu25byd4Rit+8WQYVE6WtRvqfs+RLsfmLonsYJcf7JOuT8
	GSXtWBMg5xMFJLQY0QiRaxtmnRe0BEWCFBtc+Pb1hS4IwIqmueT+UNRngMyK9kTVqt0cjqbTCtu
	MVHhHptQ38cGcv6enr17ScPoL+bHOEk1BnTnfRGHTVDDChBuwMXz7yWkUP7AvhYnktg==
X-Received: by 2002:a19:9f01:: with SMTP id i1mr46145992lfe.98.1558612194945;
        Thu, 23 May 2019 04:49:54 -0700 (PDT)
X-Received: by 2002:a19:9f01:: with SMTP id i1mr46145966lfe.98.1558612194267;
        Thu, 23 May 2019 04:49:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558612194; cv=none;
        d=google.com; s=arc-20160816;
        b=ZGXjHgGMmZCkZ23V0CglLavEgFCimNfjxJ6EMS7czqZZZj+Mdz5lix66yr1tFj9jiP
         JeolDqyVvsHQDxkH9kmtnopgEXsxYGHt6lAfxMWETyKh2gtqslfxlYw3Rq4m3UZk9dfc
         2ZzpwuTYAxRL8LdTPWTn4ttJvHp5Tg3NACuJNyJMuIrKQALXa0PFPO+4pImKGzqX88wR
         4br8BaMGDAvx+qDMQpNbOHYyDQWIFmXxkfA0OSU9XkYVM6n0d5L/KIF7zCwGzls4wqkc
         vac4a6xUU610+i6Ngaqf6VaXVOh2/zUQ43KQZt9IS6rOgKLUbl3fSyrUKfvNMKLoXvAx
         gcUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=YevW+X+2+POPi7PMf63t0Xk4zVo6kPahAFQzxSKuB6A=;
        b=A1hYNhMK36NjcUYOmj2s1ualb/TD6qUB1ScFLtrPPmel6m+UWTmsiEMOIDhdWAplxa
         mZCxPCT+kk6OV4JpW3HygqIK9vdYxaIlKmos3Sgr20xAONhZhVsDdjEGhtb1UtLXHk8h
         XKaUbQ3y8IOmu+KuVpoXWTkHE778p1FQKrhJRyWYTmkkikJypJK0TYXsAiW5AFkV9Aol
         9GAOtrBIxKkYGNWY12NW2pl03t6fCvKWutGfsBrrNgJ/F9fNy7ud6DZ3TnDNylmj5/vp
         RWEtx+OfMNkGgwWF/XNNXopIeDCysO5aCYeEOM5wL9MhSQS07uy3BfhW+BISvdkCqr0A
         gftA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="BY/HQXW/";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d24sor7097777lfl.31.2019.05.23.04.49.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 May 2019 04:49:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="BY/HQXW/";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=YevW+X+2+POPi7PMf63t0Xk4zVo6kPahAFQzxSKuB6A=;
        b=BY/HQXW/klTF568pBiSEXjI8idFQLdUtOcmhIaTb6gq+YhCaklihF99CBnhri+5r0v
         cLFUwZ/n/tNUMFXdr+/mkWC0Xe1IPnH4w80SbAKPjH3u3bv2G/gUG8DGHv7gzA+d0Sli
         2iUmfXZexxYgS8DmUKKCQ69WOKBr5mGMKB6RmDc93Bn8/kWgvHnb7jEY8ZcOx3nbWLFM
         RL5dkF2ZuIKaPN7BUqq9IuGssUQikoO6qgf2ocbX+VgTJa4I/otp1g3k57PrB+bT9NP9
         TQBWG+vDovPa7mV0qXPq6Aac21hymbSGq1bLBt6OKVeWSbXwQYvZ2LEBLsLkoZoQZncL
         zz1w==
X-Google-Smtp-Source: APXvYqy4q/Gsv+Imt0hcA2GhAtXoLBa35Ypwc9Y67jsM17tDnshGvZ1t6u/2M9JridJ/nRnly/zAlQ==
X-Received: by 2002:a19:4811:: with SMTP id v17mr40677474lfa.10.1558612193842;
        Thu, 23 May 2019 04:49:53 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id y3sm5920528lfh.12.2019.05.23.04.49.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 23 May 2019 04:49:53 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Thu, 23 May 2019 13:49:50 +0200
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] mm/vmap: get rid of one single unlink_va() when merge
Message-ID: <20190523114950.cugrtqcz5hleczyd@pc636>
References: <20190522150939.24605-1-urezki@gmail.com>
 <20190522150939.24605-3-urezki@gmail.com>
 <20190522111911.963fbb4950e051a35e92887c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522111911.963fbb4950e051a35e92887c@linux-foundation.org>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 11:19:11AM -0700, Andrew Morton wrote:
> On Wed, 22 May 2019 17:09:38 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:
> 
> > It does not make sense to try to "unlink" the node that is
> > definitely not linked with a list nor tree. On the first
> > merge step VA just points to the previously disconnected
> > busy area.
> > 
> > On the second step, check if the node has been merged and do
> > "unlink" if so, because now it points to an object that must
> > be linked.
> 
> Again, what is the motivation for this change?  Seems to be a bit of a
> code/logic cleanup, no significant runtime effect?
> 
It is just about some cleanups. Nothing related to design change
and it behaviors as before.

--
Vlad Rezki

