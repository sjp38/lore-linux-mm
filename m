Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF575C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:01:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9671F20850
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 19:01:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9671F20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45F166B0003; Wed, 20 Mar 2019 15:01:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E5A46B0006; Wed, 20 Mar 2019 15:01:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 287866B0007; Wed, 20 Mar 2019 15:01:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 02BF86B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 15:01:25 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id v2so3099232qkf.21
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 12:01:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=aRCR+a3ksABse4inSLhWXoW+DTZZJel0b5kXwJ9saVg=;
        b=tIaH8NfbDg44ktXzo61FtGOYPEKHk4rz3nVkcFncsHCrIr2mJyL34+JpY8QSyuNXGS
         24EdaZr7Ul06HhD0+DVqUW8EdPBJB937fdUcPD6X7TvzyeQK1O0t8Q7FAtdrQsKQ0ech
         6kdmTynslObZvyzTY7VdmmWIp0yoVJCcPNhbCX+P1F/w27XPDNZmJ8GyyovpR+xzUIRC
         23kSKf5XIS2pVet0LuLZF5BQW+hHOsy1KdnAlObQ2q5ucg4+bk/+K2giF9sVPTGr1YOg
         uVG7tisRey08znTufPdL00jnTqNTOrNsfPhjqHvvozrgFolPREoEeMGCZToys9KSQ1/N
         jY4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWD0JnxmRLLjKoXfLdcWqcKdqxAOosolmOKae5JdYXjISIPYMD9
	dfZ+YgtE+KnzHxYhXLUTqd9lYeZe5ubBrd+yrFxcVp1bgCXzxdGACAUX7f7sfiJk1e4eLjI96YW
	BIseRuUEB0paLwoEI1MSWf5+Y7k2KVDjmcsq5eOh7bl7ltJ0ZHga0hx9PfRQHOWn3uQ==
X-Received: by 2002:a0c:c3c7:: with SMTP id p7mr7948154qvi.162.1553108484784;
        Wed, 20 Mar 2019 12:01:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNRx+lIzCcrnJ4sBP7Kshe5q7Ei5Hmy3reDgOurU67br7Sd479DuNe2ihogYBKo8SSt8aT
X-Received: by 2002:a0c:c3c7:: with SMTP id p7mr7948114qvi.162.1553108484187;
        Wed, 20 Mar 2019 12:01:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553108484; cv=none;
        d=google.com; s=arc-20160816;
        b=oylypnB1/2wdkk2oeACp1/At+4vsVQ55n0KOmnQYxY743GDb5JSg8HLADSyXifhXxH
         Wn2Bl/ZMd8CzudGKVekU673RscSAiMl6DIqqPyxTWpghWWl26m0umcGbRlk+3Tmv4K/R
         qAs9jNEjj0psNGY4eK7ny7Be36zTH8PkDnrFnT5rlHNmij9qDBqZgAHyZBiaO8BZjB8Z
         eqmj5/wEcDFNFkGiuObaaIfWmHVCBEK20uawB9gI6wUGIpwS+3zFAkNdhXJKL9tq0KqE
         DA0iknqYnYkJ8uxg7ta4YwVD1PoIcbYz+i/SAO7vstdlutcp5ReXDbucHjDObivhBCuk
         Pddg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=aRCR+a3ksABse4inSLhWXoW+DTZZJel0b5kXwJ9saVg=;
        b=R/RNKl63QbPucqiWJNqrbEsovh/obChIsLemE0N0mObDV28EoXMOZ0gLM2FmDFVpV7
         ZJ0PfgLy910ZnnucSJj3weTMf4O492NbCfmKavyWLkXE3OwKzbT6PVVxv9/QQwVxkSBa
         3Voq+aCsKR5Ehto4Oxy6JNszsBmP/DS5THoaftDd4pwQ2owOa14WGAHO+FAnJnhpZXth
         +lpNmad/2ESFPeenLPJspVmuyWWqiTE9g8Cn2FZV5EAwrUyoXO2k/0OEMacp4o6Q+A8A
         EFh5RGI5d37M2LtIbBxu/3FKuDr7EPj2T2XvvinRGmfmPKBj+EnI2KZqElJiZxXBEgaE
         mycA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e65si383516qtb.267.2019.03.20.12.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 12:01:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B337C307B48B;
	Wed, 20 Mar 2019 19:01:22 +0000 (UTC)
Received: from sky.random (ovpn-120-78.rdu2.redhat.com [10.10.120.78])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1864460852;
	Wed, 20 Mar 2019 19:01:13 +0000 (UTC)
Date: Wed, 20 Mar 2019 15:01:12 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Xu <peterx@redhat.com>,
	linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 1/1] userfaultfd/sysctl: add
 vm.unprivileged_userfaultfd
Message-ID: <20190320190112.GD23793@redhat.com>
References: <20190319030722.12441-1-peterx@redhat.com>
 <20190319030722.12441-2-peterx@redhat.com>
 <20190319110236.b6169d6b469a587a852c7e09@linux-foundation.org>
 <20190319182822.GK2727@work-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319182822.GK2727@work-vm>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 20 Mar 2019 19:01:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Tue, Mar 19, 2019 at 06:28:23PM +0000, Dr. David Alan Gilbert wrote:
> ---
> Userfaultfd can be misued to make it easier to exploit existing use-after-free
> (and similar) bugs that might otherwise only make a short window
> or race condition available.  By using userfaultfd to stall a kernel
> thread, a malicious program can keep some state, that it wrote, stable
> for an extended period, which it can then access using an existing
> exploit.   While it doesn't cause the exploit itself, and while it's not
> the only thing that can stall a kernel thread when accessing a memory location,
> it's one of the few that never needs priviledge.
> 
> Add a flag, allowing userfaultfd to be restricted, so that in general 
> it won't be useable by arbitrary user programs, but in environments that
> require userfaultfd it can be turned back on.

The default in the patch leaves userfaultfd enabled to all users, so
it may be clearer to reverse the last sentence to "in hardened
environments it allows to restrict userfaultfd to privileged processes.".

We can also make example that 'While this is not a kernel issue, in
practice unless you also "chmod u-s /usr/bin/fusermount" there's no
tangible benefit in removing privileges for userfaultfd, other than
probabilistic ones by decreasig the attack surface of the kernel, but
that would be better be achieved through SECCOMP and not globally.'.

