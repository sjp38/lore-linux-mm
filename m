Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D7A1C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 14:33:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3441E217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 14:33:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cCOBoICU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3441E217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0DF26B0003; Thu,  8 Aug 2019 10:33:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBF1C6B0006; Thu,  8 Aug 2019 10:33:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A876C6B0007; Thu,  8 Aug 2019 10:33:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D1B56B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 10:33:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f19so58362062edv.16
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 07:33:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1+hRXOJC+ZDM/4/kVVufU5PRo9dpiWo2Z8YGtmpPW2I=;
        b=gTr4s3Ij1Aqhfdmqz6LXVsILYmYEfFYGqDd/TRR+DWe6dXhlTTUXmb/aSDJHwRYD1b
         B6BiiOzXPjCbmBOXSFmSVu3lJF+sOjiVQ+5jRG42klOUxxDHgAX0ZYX2dfp806sq3pUp
         I4pVMywlQeZwcbtWQ44lb0CgHdTx20spSG7QTfA6LS9At9Xcz9ybj0L+2FJ19BoOB3rz
         zc3emdTsWvwE3h9OqQZXRi3FKsHzSnDzIEtxQ4hsY2diVAp7x98VhW5+Gu8JDOkG0j+l
         QiCkhc9B3++SU4KMYLJTjGGID4bkZ0kxrHpgXyhTXS3Mm9fj/2OCxvvvHopT2KzBi7An
         qolQ==
X-Gm-Message-State: APjAAAUz9swzDLk0vGqfrVtfdJ+DeYK6aduoBI8fWZVJPQ3KBFqVWC5B
	8/5MMLiUrz2tfsKVnYGRROdKEkGrVKy7uCsmnK38GqYWL9rrzpv81iWkMcwzQu5Uk2H9h3XGWKl
	nMDeaSg1JrTWodtamUIj8zGjDxhDXpMvq3wSBRTVexHg/aY1MWYdDcSICfW7ahBJMNw==
X-Received: by 2002:a50:f70c:: with SMTP id g12mr16386449edn.139.1565274818967;
        Thu, 08 Aug 2019 07:33:38 -0700 (PDT)
X-Received: by 2002:a50:f70c:: with SMTP id g12mr16386385edn.139.1565274818262;
        Thu, 08 Aug 2019 07:33:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565274818; cv=none;
        d=google.com; s=arc-20160816;
        b=lI93ixc/yWkfpSq2iP6Jk3bfuK/W7Dbx2eGyaOeBopvV2N6M4l4pilaqYQDveFEY+6
         xCMYgVDtfW8l0ZTgGU8dVSip1HXECr1dbu2j/n1DtCeZ8y4HQkctz1Rs3RUN4ebAJf83
         FxsEsxe+lUm81nCViHZ1v5e6/WtFxYG/SoXF9LWfDguIUM6NaqkK0/5yeHUKhloGYYVq
         2eXi19obJ+v4/dP4EOO8sVPwhhSv5aQdr2TgBYfTfc9wTxx7dibnnJMvDCw0eGeAKiRF
         s/ypDtmeJHosuU6rzmRn/RVU6oHSRML0Padb73VTrBT6dWXYIXh1XsGv16x80XMS2QFb
         4a1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=1+hRXOJC+ZDM/4/kVVufU5PRo9dpiWo2Z8YGtmpPW2I=;
        b=oA7Ialpfq7nx8O/tvv3CD2AsIQTTj5vD1AMKar77FUiRR1rafDxHXaU9tYWiC6ZJFZ
         jyALk9aEgq0nblIH4ForcMkSK/ZFbynlhoTD669KhhfylK2XseWkWq8pcPdGV4pE7tMF
         hvBMyD7fgq6EO+Q/AkFKz0vhsKmzLj9GtGuxSCTv5PChUw8YEujNz70nxb3oYIlvAScv
         Fg8pM1DCJAGJrqJ6yNTtUgl0T8mZ1wiv+QgggTIpWAiASJCwmNkyBtLI7ZEWRzL4M3fP
         4BfcVwDOO0tODXVT2R9QtPXMNlE2HrrgDYT5vA9Q/DXlyc8xxrcDIYlxI1oEMjQw8g8n
         k3Aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cCOBoICU;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m20sor33220461ejk.32.2019.08.08.07.33.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 07:33:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cCOBoICU;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1+hRXOJC+ZDM/4/kVVufU5PRo9dpiWo2Z8YGtmpPW2I=;
        b=cCOBoICU8CNt81EgZopFsi62bJmq0dCGhRRyOBZrHz6x4zgZMVW0I0qIH4tqKn99Ch
         KCuglEQChTF0oNH1RULG7gBFl9ROMSdkWPvDjWYgtyOrwC7lBeww1a4RHafAsavxSbuz
         Fm5M+8QkjJbkTLchwoDqDiNyYbvLWr++v5jvUHZn519FGt5V8pAxBJ4xQpWhD/gIuloD
         XKVlh5ov7P2gm1HzEQ48jtXVuZeHjUX32eyJr6Bqts2hiTE9KbIsnJiV+CpxXmKThH2e
         wmRBJg1RkKYjzuvNjK7zAtt1JAO3piFKSeZxcWyHrAMwdAXPw6YlB+ETRwL/ZUXfkWia
         2s4Q==
X-Google-Smtp-Source: APXvYqw60Qv6BR5nyiLLGJOB6JFXkK8yFSkjUH6a9VxpLPc86WgYOyY4BHMmwi1P9oj0mhGac7YRMA==
X-Received: by 2002:a17:906:4354:: with SMTP id z20mr13315954ejm.163.1565274817932;
        Thu, 08 Aug 2019 07:33:37 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id m17sm255658ejc.91.2019.08.08.07.33.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Aug 2019 07:33:37 -0700 (PDT)
Date: Thu, 8 Aug 2019 14:33:36 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Wei Yang <richardw.yang@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org,
	kirill.shutemov@linux.intel.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/mmap.c: refine data locality of find_vma_prev
Message-ID: <20190808143336.kgq4f6j5gfixtcb4@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190806081123.22334-1-richardw.yang@linux.intel.com>
 <3e57ba64-732b-d5be-1ad6-eecc731ef405@suse.cz>
 <20190807003109.GB24750@richard>
 <20190807075101.GN11812@dhcp22.suse.cz>
 <20190808032638.GA28138@richard>
 <d4aab7f0-b653-8636-b5a7-97d3291f289d@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d4aab7f0-b653-8636-b5a7-97d3291f289d@suse.cz>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 10:49:29AM +0200, Vlastimil Babka wrote:
>On 8/8/19 5:26 AM, Wei Yang wrote:
>> 
>> @@ -2270,12 +2270,9 @@ find_vma_prev(struct mm_struct *mm, unsigned long addr,
>>         if (vma) {
>>                 *pprev = vma->vm_prev;
>>         } else {
>> -               struct rb_node *rb_node = mm->mm_rb.rb_node;
>> -               *pprev = NULL;
>> -               while (rb_node) {
>> -                       *pprev = rb_entry(rb_node, struct vm_area_struct, vm_rb);
>> -                       rb_node = rb_node->rb_right;
>> -               }
>> +               struct rb_node *rb_node = rb_last(&mm->mm_rb);
>> +               *pprev = !rb_node ? NULL :
>> +                        rb_entry(rb_node, struct vm_area_struct, vm_rb);
>>         }
>>         return vma;
>> 
>> Not sure this style would help a little in understanding the code?
>
>Yeah using rb_last() would be nicer than basically repeating its
>implementation, so it's fine as a cleanup without performance implications.
>

Thanks, I would send this version with proper change log.

>>> -- 
>>> Michal Hocko
>>> SUSE Labs
>> 

-- 
Wei Yang
Help you, Help me

