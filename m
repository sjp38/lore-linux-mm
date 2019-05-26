Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2399C28CBF
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 20:17:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AF2920863
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 20:17:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nLMGJ2BF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AF2920863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDCAD6B000D; Sun, 26 May 2019 16:17:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8CF66B000E; Sun, 26 May 2019 16:17:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7BFA6B0010; Sun, 26 May 2019 16:17:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id AAA3F6B000D
	for <linux-mm@kvack.org>; Sun, 26 May 2019 16:17:25 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id t17so7793070otp.19
        for <linux-mm@kvack.org>; Sun, 26 May 2019 13:17:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=3uf9cufEGhDoTEnfE1h9K1llyrP8ckDtJqezj61tU2A=;
        b=AoNGTNimNGPW/g6Sdmx7jD34feD683iFD0jzEGjxnDUTBwq1oplAToEV/RtuVJUSv0
         YmfOKvWRzOp8fKGJJlpD7JNtAPuOqMuX3TGvheShfgInMCesJbOAxHlw88bCgh6qOYZU
         4rl/Obnf4G8DR6FpbBPZX7Xhldzm2JSntWLsiHDyHUR3E5custM6dCNBX9lvRdfRWaf+
         P2lDJJ9mMt1prrNkfhlsUWqH02nwHHoDmxUfZMH7RqBa+H+1qp2vlcFtMSg3N8ray+0L
         d04D5qWooFWwBh9vlOpNz+YifJP+QHCvuCfESV5miQynYID5yz4DCNmTfLM9sLou0Pox
         9N2A==
X-Gm-Message-State: APjAAAXvGDFrXXXpgSxM7FOQqf4uUbHP1p2eQhkgw2U13davY7ANJPwt
	3DQIfhX7/rjgd6zKkLO0VC36vST4NeFVREDeeebE+GGBRzeKkyIWymkggJIL3WxhNZRqcFOuSP0
	/HicIOE7PS/lVrDSU5sRGEMHFHE4T+pPbzMapCc0ipN/Fl5/Cpr8F/QImGiMSMj9ubA==
X-Received: by 2002:aca:3d54:: with SMTP id k81mr12112958oia.111.1558901845202;
        Sun, 26 May 2019 13:17:25 -0700 (PDT)
X-Received: by 2002:aca:3d54:: with SMTP id k81mr12112944oia.111.1558901844527;
        Sun, 26 May 2019 13:17:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558901844; cv=none;
        d=google.com; s=arc-20160816;
        b=jA6YRN9e92yU++qxlU4L4RuOAsAOq+VKk1X6IaTOacgwBeFoF6vfuZsn0E2x1D06la
         9JQtwIwEf3IidDTFkDuhV+IqE4GvGLzqMagVY/g64YvXf8jgEn2fFQivUPEKjd8M1+22
         dOL0yUfOFZ5LzvkvVnVAWRRA9fPe58UXDwvLjoW3BZENfHfh5o+cXZ2tZi0maEtZjmng
         WVV2WRO5npYu12C6eC9ruyIgLzCqcv5O4FeinOKeB7ew2OmwhtoTLvQrQj3AQKPfdkIt
         fB7Rg2mz+LTZh4kkm2RRBBh7J9R0A6GogfT2CuHwvqN4cJ4vMNyhrZXkwvbY2TpLuugs
         RwyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=3uf9cufEGhDoTEnfE1h9K1llyrP8ckDtJqezj61tU2A=;
        b=mocair4A28V6B0q3RPHIoCprNlgPx9zJePmhfJHSnPJ+Wb/ry7y+sRnmpH77Z7GSwe
         lmzFBr2smFneJjBmRaYkeJ39AAt6DNfxX0cvVWPqVOtdhb3ATcOmT52kLi9BN/bN3pXU
         zYyEu15V6eR+E9OompL0BkjYeJ77xc5mRQioysHAocPpWCUZpoVMRvzm/TPBjrRH9wcE
         4JJ/gs9vD+0baz89ELT6cpka3par+eZHOWO53sndHYqNpF158yUONya8zwY3JsnCan6u
         pma8v7lMP65tMHTksuiv2n6Ot73syCWH2XLoAwCJNo2k7XbsxSaJ00trA2f1J+1chsDd
         vBkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nLMGJ2BF;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j6sor3200298oif.45.2019.05.26.13.17.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 13:17:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nLMGJ2BF;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=3uf9cufEGhDoTEnfE1h9K1llyrP8ckDtJqezj61tU2A=;
        b=nLMGJ2BF8srHOOyJh/mHZ+qgHENvX00rMwG1YC5XDW+oB79h7ArHJXQb8We3lHho4h
         d12+FULqFsV9zjbIaxsTd4lGID9t8s6c9vKIlCg/NH99awYHv7oqKPTIX3jCfYSpr71J
         x/Qj+tJfy2B52URYJMaGyvZhsgVKaUruiccUSA7a8509NFBUryqERZo25UjLYReosVhQ
         xPIKQ5xv6d0+5Lv7/eFpMvXoM57SubmnNNg2SnMbvAHtz1M335o9QczoN26rxjal9+Vb
         q6YXLyNgAaKWB+c2TEAZwBRNFhk3xupR1pH6HgI0or9vFTa414LPRQjE7FfTJEHZm4pl
         Tx+g==
X-Google-Smtp-Source: APXvYqy4mE9GkvIYIH0dQKiRyKKl0V5oqT23k8QaDoMApbh2MokN1Ee0p6duj/olz9iuQdHSNYBk4w==
X-Received: by 2002:a05:6808:603:: with SMTP id y3mr394497oih.74.1558901843688;
        Sun, 26 May 2019 13:17:23 -0700 (PDT)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id e4sm3189630oti.64.2019.05.26.13.17.21
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 26 May 2019 13:17:22 -0700 (PDT)
Date: Sun, 26 May 2019 13:17:03 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
    Mike Rapoport <rppt@linux.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    Borislav Petkov <bp@suse.de>, Pavel Machek <pavel@ucw.cz>, 
    Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
In-Reply-To: <20190526193651.spvm2vtrwxlhsjrv@linutronix.de>
Message-ID: <alpine.LSU.2.11.1905261250590.2394@eggly.anvils>
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com> <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org> <20190522194322.5k52docwgp5zkdcj@linutronix.de> <alpine.LSU.2.11.1905241429460.1141@eggly.anvils> <20190525084546.fap2wkefepeia22f@linutronix.de>
 <alpine.LSU.2.11.1905251033230.1112@eggly.anvils> <20190526193651.spvm2vtrwxlhsjrv@linutronix.de>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 26 May 2019, Sebastian Andrzej Siewior wrote:
> 
> Okay. The GUP functions are not properly documented for my taste. There
> is no indication whether or not the mm_sem has to be acquired prior
> invoking it. Following the call chain of get_user_pages() I ended up in
> __get_user_pages_locked() `locked = NULL' indicated that mm_sem is no
> acquired and then I saw this:
> |                 if (!locked)
> |                         /* VM_FAULT_RETRY couldn't trigger, bypass */
> |                         return ret;
> 
> kind of suggesting that it is okay to invoke it without holding the
> mm_sem prefault. It passed a few tests and then
> 	https://lkml.kernel.org/r/1556657902.6132.13.camel@lca.pw
> 
> happened. After that, I switched to the locked variant and the problem
> disappeared (also I noticed that MPX code is invoked within ->mmap()).

Ah, I wasn't following what happened here while it was in linux-next.

I certainly agree that all the variants are very confusing, and the
matter of mmap_sem particularly so. Because it used to be a simple
rule that you needed to hold mmap_sem to call get_user_pages(); but
that can be so contended that get_user_pages_fast(), and VM_FAULT_RETRY,
optimizations came in, then interfaces like get_user_pages_locked() and
get_user_pages_unlocked().

I think when you say that you "switched to the locked variant", you're
writing of when you switched to using get_user_pages_unlocked(), which
takes and releases the mmap_sem itself: yes, using get_user_pages()
without holding mmap_sem would have been open to serious errors.

The documentation in comments above get_user_pages_locked() and
get_user_pages_unlocked() looks rather good to me, actually.

But this is all good reason to use the less challenging
fault_in_pages_writable() instead. (And also saves all those GUP
developers, who from time to time have to search through all users
of GUP in one form or another, to make this or that improvement,
from having to visit arch/x86/kernel/fpu/signal.c: they will
quietly thank you.)

Hugh

