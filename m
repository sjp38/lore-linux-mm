Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 24D4A6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 08:46:43 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w102so8178480wrb.21
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:46:43 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id h125si10079421wma.136.2018.01.30.05.46.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 05:46:41 -0800 (PST)
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
References: <20180124175631.22925-1-igor.stoppa@huawei.com>
 <20180124175631.22925-5-igor.stoppa@huawei.com>
 <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com>
 <6c6a3f47-fc5b-0365-4663-6908ad1fc4a7@huawei.com>
 <CAFUG7CfP_UyEH=1dmX=wsBz73+fQ0syDAy8ArKT0d4nMyf9n-g@mail.gmail.com>
 <20180125153839.GA3542@redhat.com>
 <8eb12a75-4957-d5eb-9a14-387788728b8a@huawei.com>
 <CAFUG7CeAfymvCC5jpBSM88X=8nSu-ktE0h81Ws1dAO0KrZk=9w@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <5782e30f-76b3-cf6f-e865-666aa958685e@huawei.com>
Date: Tue, 30 Jan 2018 15:46:37 +0200
MIME-Version: 1.0
In-Reply-To: <CAFUG7CeAfymvCC5jpBSM88X=8nSu-ktE0h81Ws1dAO0KrZk=9w@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boris Lukashev <blukashev@sempervictus.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Jann Horn <jannh@google.com>, Kees
 Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Kernel
 Hardening <kernel-hardening@lists.openwall.com>

On 26/01/18 18:36, Boris Lukashev wrote:
> I like the idea of making the verification call optional for consumers
> allowing for fast/slow+hard paths depending on their needs.
> Cant see any additional vectors for abuse (other than the original
> ones effecting out-of-band modification) introduced by having
> verify/normal callers, but i've not had enough coffee yet. Any access
> races or things like that come to mind for anyone?

Well, the devil is in the details.
In this case, the question is how to perform the verification in a way
that is sufficiently robust against races.

After thinking about it for a while, I doubt it can be done reliably.
It might work for some small data types, but the typical use case I have
found myself dealing with, is protecting data structures.

That also brings up a separate problem: what would be the size of data
to hash? At one extreme there is a page, but it's probably too much, so
what is the correct size? it cannot be smaller than a specific
allocation, however that would imply looking for the hash related to the
data being accessed, with extra overhead.

And the data being accessed might be a field in a struct, for which we
would not have any hash.
There would be a hash only for the containing struct that was allocated ...


Overall, it seems a good idea in theory, but when I think about its
implementation, it seems like the overhead is so big that it would
discourage its use for almost any practical purpose.

If one really wants to be paranoid could, otoh have redundancy in a
different pool.

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
