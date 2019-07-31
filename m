Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16352C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:09:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6998206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:09:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6998206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B7728E0006; Wed, 31 Jul 2019 08:09:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 669228E0001; Wed, 31 Jul 2019 08:09:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 557DF8E0006; Wed, 31 Jul 2019 08:09:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0632D8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:09:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so42260947eds.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:09:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ra8tXXWM7gy+WmKNtEEGrZMrY86/ZtGlHA6azAo4ss0=;
        b=N3HmzJaz4u+VpuPMv2bKstWACxQcTXkzoYdqtPrcQhgCNgqM07ETdvwbkYj0t5JGfL
         mV7KjSjS7xsrYITyFuI7pS1d7TBo98lk3QuOsPZk5MtfqD4EFMESh6z/5sdNjr9eq6S6
         g+/NNj4qtczpWs5O3wQbkXtwVtmmFiilBiVgCE1j4Q6ytdeOroSlvyUNPfcaoY34ss1i
         hKdehd9TVV+mixA+HaKWeYTt/Uyg4hkvx1b7vYiPsldBhI0/QvblmeVpR0H2jgPEhI4j
         TPTuUM3w4ejiHDWuc/RuU9/DXCqbgHKuLT2vBP7QShytxE/kKJ9q5TiuwEvE1iqGRfZO
         Eb/w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWn0+owBgPXEiV3Q1wtxrQLCLlMH2sUecx+SmodD4ZPRpOFq2lD
	JGSq/Eofcmi/L4R4ja5gGnplYymzjXyjpPSCjigq7CP9syFdWKGP8trcUMNF+xl/2Y+uaWH3mP8
	sX5cCTjv9uh+TzKKjQS9Bl18SWNX77xBlMNk7RZza7doM3KeC1O3NxBIgXGDTcOU=
X-Received: by 2002:a50:aa7c:: with SMTP id p57mr107021022edc.179.1564574941605;
        Wed, 31 Jul 2019 05:09:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPaw7HRb5He3/XyMG9xcR5eHMjOQi0YOcciyL+uROfGatLNaZ3QK0EqXPfj6Qb+BPxzF8h
X-Received: by 2002:a50:aa7c:: with SMTP id p57mr107020952edc.179.1564574940834;
        Wed, 31 Jul 2019 05:09:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564574940; cv=none;
        d=google.com; s=arc-20160816;
        b=efX7JIEbrLUUZ6D93RcdP80gh7/0hZ/Zqz5fPwgsjNihe5Q4Q9p1Ru4Jli+Cxprab0
         ySeuqx5uyBtLRq9cgRkYsN5j30P6Fn5H3qmFUyWc9R9+D1ths4/gJrW7kbq/rBuFcmTl
         sqgDcQmUc+9ksUTW6B78M5b9Aatnh5kfe3xTp00g3EHz8eIksnk2OtlFa2JoyYjlU9bR
         CUSnHiaOsURHfGxOOxTwqvWQ1sTkFBcFSMa4GoJMw9kK5Zh9D9cF0mJiKwKX00GeDx0t
         9SDX0dZDPU+8hSkxS43Kby4zl/NzbJpQioy7sQLHAPk5qQRD7NtV6IMRTopKmso1glyt
         BYgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ra8tXXWM7gy+WmKNtEEGrZMrY86/ZtGlHA6azAo4ss0=;
        b=TxKvsZb4hTQjcPEKvWlLPVQK4My7xh/6g8gpov1vfK+HDMNi36kj9jTE1YT2OsRShW
         mPJ4u60wMLHyRJhyuOfnni8A33fEft+VMUTQFrygYM5qwvMkVErlFhyRSonD3Ho0dCYq
         hjYmz+uvofZVETwK/aRTIzJte5yvIEdi105EU9qG7OKWN9rsfkq1OOSSAXNl7gofRs+a
         t3FR8kWAtDcByNsFPR7NWv8hJ3o6qpNGB81+YD6tY4qh5LdDDd+8dhtcRyVR7u6O9gnm
         QtPkew5DdAIi6URciDzZgPDWlYkkNOCldW+q/E6LM8QWp/F3oTendbkrVM+rcI5MlENG
         IFSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y9si20065764edb.262.2019.07.31.05.09.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 05:09:00 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 56879AF30;
	Wed, 31 Jul 2019 12:09:00 +0000 (UTC)
Date: Wed, 31 Jul 2019 14:08:59 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Rashmica Gupta <rashmica.g@gmail.com>
Cc: Oscar Salvador <osalvador@suse.de>,
	David Hildenbrand <david@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>, pasha.tatashin@soleen.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
Message-ID: <20190731120859.GJ9330@dhcp22.suse.cz>
References: <20190625075227.15193-1-osalvador@suse.de>
 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux>
 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
 <20190702074806.GA26836@linux>
 <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAC6rBskRyh5Tj9L-6T4dTgA18H0Y8GsMdC-X5_0Jh1SVfLLYtg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-07-19 18:52:01, Rashmica Gupta wrote:
[...]
> > 2) Why it was designed, what is the goal of the interface?
> > 3) When it is supposed to be used?
> >
> >
> There is a hardware debugging facility (htm) on some power chips. To use
> this you need a contiguous portion of memory for the output to be dumped
> to - and we obviously don't want this memory to be simultaneously used by
> the kernel.

How much memory are we talking about here? Just curious.
-- 
Michal Hocko
SUSE Labs

