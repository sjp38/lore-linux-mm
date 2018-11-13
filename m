Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98A166B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 15:27:20 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id w6so5191608otb.6
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 12:27:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 101sor12274505otl.44.2018.11.13.12.27.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 12:27:19 -0800 (PST)
MIME-Version: 1.0
References: <CAG48ez0ZprqUYGZFxcrY6U3Dnwt77q1NJXzzpsn1XNkRuXVppw@mail.gmail.com>
 <d43da6ad1a3c164aa03e0f22f065591a@natalenko.name> <20181113175930.3g65rlhbaimstq7g@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
In-Reply-To: <20181113175930.3g65rlhbaimstq7g@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
From: Jann Horn <jannh@google.com>
Date: Tue, 13 Nov 2018 21:26:51 +0100
Message-ID: <CAG48ez29kArZTU=MgsVxWbuTZZ+sCrxeQ3FkDKpmQnj_MZ5hTg@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@soleen.com
Cc: oleksandr@natalenko.name, linux-doc@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, timofey.titovets@synesis.ru, Matthew Wilcox <willy@infradead.org>, Daniel Gruss <daniel@gruss.cc>

+cc Daniel Gruss

On Tue, Nov 13, 2018 at 6:59 PM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
> On 18-11-13 15:23:50, Oleksandr Natalenko wrote:
> > Hi.
> >
> > > Yep. However, so far, it requires an application to explicitly opt in
> > > to this behavior, so it's not all that bad. Your patch would remove
> > > the requirement for application opt-in, which, in my opinion, makes
> > > this way worse and reduces the number of applications for which this
> > > is acceptable.
> >
> > The default is to maintain the old behaviour, so unless the explicit
> > decision is made by the administrator, no extra risk is imposed.
>
> The new interface would be more tolerable if it honored MADV_UNMERGEABLE:
>
> KSM default on: merge everything except when MADV_UNMERGEABLE is
> excplicitly set.
>
> KSM default off: merge only when MADV_MERGEABLE is set.
>
> The proposed change won't honor MADV_UNMERGEABLE, meaning that
> application programmers won't have a way to prevent sensitive data to be
> every merged. So, I think, we should keep allow an explicit opt-out
> option for applications.
>
> >
> > > As far as I know, basically nobody is using KSM at this point. There
> > > are blog posts from several cloud providers about these security risks
> > > that explicitly state that they're not using memory deduplication.
> >
> > I tend to disagree here. Based on both what my company does and what UKSM
> > users do, memory dedup is a desired option (note "option" word here, not the
> > default choice).
>
> Lightweight containers is a use case for KSM: when many VMs share the
> same small kernel. KSM is used in production by large cloud vendors.

Wait, what? Can you name specific ones? Nowadays, enabling KSM for
untrusted VMs seems like a terrible idea to me, security-wise.

Google says at <https://cloud.google.com/blog/products/gcp/7-ways-we-harden-our-kvm-hypervisor-at-google-cloud-security-in-plaintext>:
"Compute Engine and Container Engine are not vulnerable to this kind
of attack, since they do not use KSM."

An AWS employee says at
<https://forums.aws.amazon.com/thread.jspa?threadID=238519&tstart=0&messageID=739485#739485>:
"memory de-duplication is not enabled by Amazon EC2's hypervisor"

In my opinion, KSM is fundamentally insecure for systems hosting
multiple VMs that don't trust each other. I don't think anyone writes
cryptographic software under the assumption that an attacker will be
given the ability to query whether a given page of data exists
anywhere else on the system.
