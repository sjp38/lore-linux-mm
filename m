Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AB14C04E84
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:29:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 463C62082E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 16:29:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 463C62082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D29256B0007; Thu, 16 May 2019 12:29:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD93C6B0008; Thu, 16 May 2019 12:29:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA1846B000A; Thu, 16 May 2019 12:29:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 73AF96B0007
	for <linux-mm@kvack.org>; Thu, 16 May 2019 12:29:49 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id p3so1561030wrw.0
        for <linux-mm@kvack.org>; Thu, 16 May 2019 09:29:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bmJ3oGbhkIfE+oGMXz0i/1fqw7BH4scbuPzlcTLdX0o=;
        b=X7FbY1H9CBIuR2AkS54KAI1VVLrEjmjwKd/4/S8tuc85XFppao/av83qL3Psva4cCf
         jmMcFmd+5ZJo46HTczhKEjy0Q8N9lBcdDtp5csiFiI4LE1msqwEC8XQc1RaQwiR2oNqK
         eFK5Rp+EGB9RZ0nQ6m2v1M1PTHic//JaqfElqdayFUODR1P7YJ6L0mH0qC42te6vK1k/
         8yZlc4Xyu+utncBnxpEd6+bCwv4HtUN7ytfc+GGVBTiPw6tB6FQbnSdZ09rTrmE2/ONB
         u03F2ZkrN5C79Mdp8t+eFr9KxtlYOzy+7kdC2Ar9JVEKp0DHez6JBAXi4xNB0WaErdlw
         KDQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=atomlin@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXnZWZ3DrXBVQzzEIEZFGG3YnLAnCu/doOjksMEpNjcGP7EpB5Q
	l1ngjZ8pEroTWNmxW+pXKO8oPSPuniEC3E7wMbdxoRgRdmFnJVQoIiTiX3uMEyf2NTDvOoWgeQH
	7cy3VFOKUgRKTlf2AAAoxDka8RzLFjj4MVWAhBfGXXqt2BUmF8nNnrJ7SwEZvS/Cz3A==
X-Received: by 2002:a7b:cb16:: with SMTP id u22mr28174230wmj.60.1558024189046;
        Thu, 16 May 2019 09:29:49 -0700 (PDT)
X-Received: by 2002:a7b:cb16:: with SMTP id u22mr28174194wmj.60.1558024188272;
        Thu, 16 May 2019 09:29:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558024188; cv=none;
        d=google.com; s=arc-20160816;
        b=UboR9QQWa8Vxr6KVO1rEmdJ7UlgThguo5UURnYEddDVCJZATm09iFKbKj0+B5GypVt
         RRPTF0ST04w3/z4jtJhVg0N6Y4tG2JFT/3FmbCR7yOX0dC+/P9Xn7oLAt4BLpqpkXByM
         zafxuUSFuZByzlgKWHDEp5pHVU0qH6gzNoDP9rYcesotTDQ6nDQXRjfyu+cdRvb8Cvos
         m2eqzTm2WBNnCbE0eROw0jR6Llm8Gv4OsfkYMYJB2FJKXKxOB+SDLK46GLxNyohJ9WSZ
         CBkf7rUxK7VWbP1fYGSvi8ntN84C1/zrsF9HTkZYnUd9wO/k8scxur/TQVeT5ggZOx+Y
         ERoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bmJ3oGbhkIfE+oGMXz0i/1fqw7BH4scbuPzlcTLdX0o=;
        b=TVFODM1Fh9ngc5bhP/gYSIiJ4L7sqJy+92kSiI9gQwZF0wJkzDSXvlDqByqKE1xhjS
         z52y/MVgnV2EH4QgB0qfkL3j61ISRCxZVAsqbgo789pO7S4ZIIppnnYSiX/sGfElQVko
         WDcofRV3+Q1RVPrFKsi+qSDQHWXNClmVFRrovwihHjrxyr4JHrv1lt2UL7Y+F1u/MWe7
         FHJCOM4Jxu0zt3E8XB88ofPoNUhmnFQ79UbsBNCl9aMwZX2iGDbxgzUaymyBSjILi7Om
         UbhMKqplGhknKgYQ9qf2ATYnEEguqM3Zsq+mTk9jO8U7Ehz7WFxy4Izj8zSwSMVO6/RJ
         gv4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=atomlin@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 9sor3677913wmk.16.2019.05.16.09.29.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 09:29:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=atomlin@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw4xzsO/ZHDRK8RT2D9NZpnGvFVdO15DLWHiBOzYw0vUAqtOT7NkS6GGg4mfAYLcWMR8bMLaA==
X-Received: by 2002:a1c:e714:: with SMTP id e20mr18848944wmh.143.1558024187943;
        Thu, 16 May 2019 09:29:47 -0700 (PDT)
Received: from localhost (cpc111743-lutn13-2-0-cust844.9-3.cable.virginm.net. [82.17.115.77])
        by smtp.gmail.com with ESMTPSA id l8sm7695747wrw.56.2019.05.16.09.29.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 09:29:47 -0700 (PDT)
Date: Thu, 16 May 2019 17:29:46 +0100
From: Aaron Tomlin <atomlin@redhat.com>
To: Jann Horn <jannh@google.com>
Cc: Oleksandr Natalenko <oleksandr@redhat.com>,
	kernel list <linux-kernel@vger.kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>, Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Grzegorz Halat <ghalat@redhat.com>, Linux-MM <linux-mm@kvack.org>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH RFC 4/5] mm/ksm, proc: introduce remote merge
Message-ID: <20190516162946.zwzhxkft342b25pd@atomlin.usersys.com>
References: <20190516094234.9116-1-oleksandr@redhat.com>
 <20190516094234.9116-5-oleksandr@redhat.com>
 <CAG48ez2yXw_PJXO-mS=Qw5rkLpG6zDPd0saMhhGk09-du2bpaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAG48ez2yXw_PJXO-mS=Qw5rkLpG6zDPd0saMhhGk09-du2bpaA@mail.gmail.com>
X-PGP-Key: http://pgp.mit.edu/pks/lookup?search=atomlin%40redhat.com
X-PGP-Fingerprint: 7906 84EB FA8A 9638 8D1E  6E9B E2DE 9658 19CC 77D6
User-Agent: NeoMutt/20180716-1637-ee8449
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 2019-05-16 12:00 +0200, Jann Horn wrote:
> On Thu, May 16, 2019 at 11:43 AM Oleksandr Natalenko
> <oleksandr@redhat.com> wrote:
[ ... ]
> > +       }
> > +
> > +       down_write(&mm->mmap_sem);
> 
> Should a check for mmget_still_valid(mm) be inserted here? See commit
> 04f5866e41fb70690e28397487d8bd8eea7d712a.

Yes - I'd say this is required here.

Thanks,

-- 
Aaron Tomlin

