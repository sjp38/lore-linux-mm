Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9349C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:39:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84C5E2173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:39:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qrniw8KQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84C5E2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2100A8E0003; Tue, 26 Feb 2019 09:39:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C0438E0001; Tue, 26 Feb 2019 09:39:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AE508E0003; Tue, 26 Feb 2019 09:39:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B89708E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:39:20 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q21so10574631pfi.17
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:39:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dfiBLpo8ppzHN31Df3pK9Pue7IUmmemEwHEq/+qIHW8=;
        b=XnSu4/eUaW8NbYf0r6+nZAaYSleAId5OymZkn93JE+z3IjcKevuVAOQKrqlvW4aEmu
         5gigBRUTFkCgJ7oCJvmz1NQ2uAiu9+KeRUYQ8vma97rNzn1AVta3z/a/Mxvj7kCV/Kna
         O4HCnUa4xVx5g5r+g43qI+ju23MI0kDzcyGECew4Nzn9RhdMMPtPfdgn3rGpmHd83oHd
         05iUWL5xGEeQEyTBdoaG2vP2ATxKS69EoXlFed30NO9KRwNKqJj/Tqvb4eLjStNSmIH9
         Lk2gzBIgN2gF4rZ9ifOEqMlt9tCMEsgcze55rhqrx8sEwyljhLhhnxTZ/0k9nzERtoEY
         +Cuw==
X-Gm-Message-State: AHQUAuY5FqbTFg5Zryef0suqQuRo7nHo3P0ZKjX1pkrimOx2ueMysgFm
	vysk+5m2u4T8/WAZImBIcz7q1OAOJZ9y2evCTbCgVKgGRkw+ECHn9Gt+X7Ms9X6IL0cbGTwH/Lc
	7C8TQppKNAZlMxjmRcsIq1qVav1D/P/VIYJHo+davaKAQIutERwtTHlfCvniqakmrTM15+HN4rW
	n4H/6yckqadk1g8URDLu1jZGGPjEjguDnSjc3mIV3leHchtlylKdV1BncAQiHZ4RCMRzwID1H57
	/iaEWBzeK48xCdP3FCv4XHoVqtB4dqQPFXZjhvBEH820bgSlsUHyKabcvC3mGz+VuWNCC+kKjcS
	Iw655rEpZnNsohZU5+UBWMBcOYIAsm87UkiMJyfFrZCw0+WXwhug1MJbqQs7dvq4GnMa7TLBSIY
	U
X-Received: by 2002:a62:cf81:: with SMTP id b123mr26808630pfg.29.1551191960287;
        Tue, 26 Feb 2019 06:39:20 -0800 (PST)
X-Received: by 2002:a62:cf81:: with SMTP id b123mr26808570pfg.29.1551191959423;
        Tue, 26 Feb 2019 06:39:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551191959; cv=none;
        d=google.com; s=arc-20160816;
        b=XKWFcmpiS0oGV/T4EVX3xhXTIXVoEtofylSkR98FZuTaM5i3B8Uupj10TsLGpSHOp6
         ktYqql7hvWXdXBMcnlqfJ77pYzlSH2xZZEifQpRx4MCbusu7PXnOyxKLGr5TuWcxVFGD
         jqotvBupkzJjbxahqXX3ki5htX2VIRofS89TU6z2XoGUnZPXxcBCUfr3OrczVE0dZbsa
         dOq+HXB58tOKxjT/GtedaRQXDjVDh5B7n/7LHJB9WgM/q9q5o/0Ag4kn43sMrQFhM5AQ
         yFTxcwglHgFb86KD7ThrqGizrsaPy3zJ2NwL5j38RRkDQQr+ijtCN0gcAW1KH+PA/X2F
         sl2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dfiBLpo8ppzHN31Df3pK9Pue7IUmmemEwHEq/+qIHW8=;
        b=d8DAI4SFic4oK0rv+yHU5a4q/azEYR61DIpeygMwHUKgot8KZ/HSAUmyGjLlNj1bwZ
         DHnLAjG7mKn3tbTlc2KhCsk4L18JZ9X5ihyhTD45er8Gh88figRH3chJvLflYH9W986H
         gGce9zGDNgws2P/4bIiWeOWLlB5BjXUkMpAUFE2oWZ7ZjqDrk+UmH1yEcpPQrZYICSsN
         tGjg8Wwc+r3CQ4HGMq64wO8eroUaGi/mAdGWtN8aa/9VnpPeJ930RR1w7afRTrgtNj4z
         iJHdjuVQemu9hepvq+zo/QKkhogITOEkBOu+887puiNOrF/PH8+H+D+j6Z8KSh4unLc7
         i7fw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qrniw8KQ;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d8sor18839834pgc.51.2019.02.26.06.39.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 06:39:19 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qrniw8KQ;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dfiBLpo8ppzHN31Df3pK9Pue7IUmmemEwHEq/+qIHW8=;
        b=qrniw8KQBsnVcBdkLwXYTHP1tzALWjLL3wqY47zLDB86u7VpyXqsBCFNMPUvx2rcQ5
         tleEIn43VcQEIxdaz5Lq3qoXKxfo59ovHYPtXDa7JwcKInE8AMfYDGNxNizwMWMWQjde
         EhSO6jW2VXILtMDY8JQSd+bipZZVCQ+CR0EOZ2zJgqQHGK2gbFfefcVUCOF/9F/FdN4j
         khe0Gzu8tDmq3gffWUNVCHAG7gYifd/AMvfrRv8bNWrE6v7GDGV6bjcxEvsAriDj0zwX
         9ukzSjG/hOjO6EfG3Aixqm8fiGMNQyIAiftpSDpkdyIWPy343s9BUOUiQ9YAblVGHraC
         nJQA==
X-Google-Smtp-Source: AHgI3IbzQ3IeJ3DdtureLg8xHbfzWl4k26RcwSMIdPdFZQbQ2oXfH0JWdLJfU9vlDhlDrZoE5TP5lbkNIdumuA65DBY=
X-Received: by 2002:a65:6651:: with SMTP id z17mr23465185pgv.95.1551191958932;
 Tue, 26 Feb 2019 06:39:18 -0800 (PST)
MIME-Version: 1.0
References: <cover.1550839937.git.andreyknvl@google.com> <8343cd77ca301df15839796f3b446b75ce5ffbbf.1550839937.git.andreyknvl@google.com>
 <73f2f3fe-9a66-22a1-5aae-c282779a75f5@intel.com>
In-Reply-To: <73f2f3fe-9a66-22a1-5aae-c282779a75f5@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 26 Feb 2019 15:39:08 +0100
Message-ID: <CAAeHK+yQU8khtOoyDKqmHterCa16P7oWe9AMiPnrxE+Gyb_7aw@mail.gmail.com>
Subject: Re: [PATCH v10 07/12] fs, arm64: untag user pointers in fs/userfaultfd.c
To: Dave Hansen <dave.hansen@intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 23, 2019 at 12:06 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 2/22/19 4:53 AM, Andrey Konovalov wrote:
> > userfaultfd_register() and userfaultfd_unregister() use provided user
> > pointers for vma lookups, which can only by done with untagged pointers.
>
> So, we have to patch all these sites before the tagged values get to the
> point of hitting the vma lookup functions.  Dumb question: Why don't we
> just patch the vma lookup functions themselves instead of all of these
> callers?

That might be a working approach as well. We'll still need to fix up
places where the vma fields are accessed directly. Catalin, what do
you think?

