Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A184C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:58:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DC3D204FD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 08:57:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DC3D204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85D666B0007; Wed, 17 Apr 2019 04:57:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80D4A6B0008; Wed, 17 Apr 2019 04:57:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FD7C6B000A; Wed, 17 Apr 2019 04:57:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3056B0007
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 04:57:59 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id u16so2520572edq.18
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 01:57:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=COLN4n6NcQLSfcEQKdyNUIJs0wqTwtncz2+YG46FM1Q=;
        b=JDcuQfC/uwJYleiWY1fDOhfBaTtLmvjjY1nJDWowfqMYVt7oiC3kB63QBhIsWMY0P8
         YIITFnds3GYNI48rReQ3ePUO5HrW++UWnqDtKMAzSsOEpyEXW4jnXkHbaz3fAb6QHqlo
         gsSXnDiEPIf0FyaiOUEhAU18yh2LlTV1bqj6jWFIdBhZ8lySH4FaSBh52lcmvOOd7E1q
         9jXK7r2A0OQe+1EA/4VMAf/xIS3dqWJr/KJEIAF/bc8EDmwx1ZM0v+zI6oLHphAyCvL7
         e0Z81/iMgvEoVPqZW6pGuPlE2QiIoV4wcqvE7SZqVUJNv9dUxCQbiox4jRoJFQoZ2DGO
         BGIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAXy02xVsBf89m+kBW2EEaUOwfaqnrQZtObbCjpy7zcWUO7e454k
	NGduGoLo3zo3B3/1XyH9kcz4enb8bqdBRsbzhNqMry7IKLmT9T9hiARifDRvvTxaswA2rzFwJ08
	yxbT6ceF22Yi4i5KLMgj4FfsyTlp9UVTVO88KTcZQNIxd4UnYAnXPMJvxATx/wOL62Q==
X-Received: by 2002:a50:fd8b:: with SMTP id o11mr575410edt.175.1555491478662;
        Wed, 17 Apr 2019 01:57:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+RXwxznHuss0veNUdMkRoSIIDqdH9y0uBB4hvHQFaadMXqEhZWHn6McMHGOfJfcDjp14Y
X-Received: by 2002:a50:fd8b:: with SMTP id o11mr575360edt.175.1555491477813;
        Wed, 17 Apr 2019 01:57:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555491477; cv=none;
        d=google.com; s=arc-20160816;
        b=YiSmHuJZxwwu+cqM7YmRg8t8VpsgSa6bzuslqhhxmzGZH2EvHHMJvNTWQiFWZbn0WH
         yX9pw0oAVuFjQcAnakFI4JZbanwwhylYJrNUGUxJwnwhMCCwj2ndMxedo3BShbTNAGUh
         03xMBdS4tnzICspLjNrTMEVBSlT792unhvOTnGatsTY7C4G03ag3DJuTPnxSeQYB98xf
         OIgSCoSbAe0oQq0eqOMhsvZv/R59y+OCjNsSeOY/HmeXZMKvlRhmKoIqOHMWT6eF0CDH
         zd2QpYI36nZXQ1PMl0LNusnNNiFodh1TmIg3iQvJpxwWzHy+7BiwXk/7k3uJcZhoKrtA
         4f3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=COLN4n6NcQLSfcEQKdyNUIJs0wqTwtncz2+YG46FM1Q=;
        b=hrKK5NAbxt8jVMtDorTce9yEHtM0y0GnfdwJENqlhLpoqBTvUE70+9yI/wGgrJV4sy
         hPc1/TnG1oHvnTQLKrJf2dwdq77WJteisPoK+BtPhiz8I2NWdlv7v9bR6iXAu47iVt/k
         HcnAJeUOpYBODtAbGj6+8z8KQQo31K4uxgXXlIxPsUN1qb2JtgBf1inB8zub/RTDgf+X
         JMbVjm/6xB9UKzfRjTWLkfBCXlUdQj84OX4TBarju0irkPPnYYmuseqpHbDCl47Urv/0
         E3qqp0jd/q9e9iEne/0CgnPd6e1ofVUZNbsLPCwV3WeeoaICQ9vG7UP3aPCB1j1H7rNn
         QPeg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w7si4095137ejv.170.2019.04.17.01.57.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 01:57:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4D3D1ADEA;
	Wed, 17 Apr 2019 08:57:57 +0000 (UTC)
Subject: Re: v5.1-rc5 s390x WARNING
To: Li Wang <liwang@redhat.com>, Mel Gorman <mgorman@techsingularity.net>,
 Minchan Kim <minchan@kernel.org>
Cc: linux-mm <linux-mm@kvack.org>
References: <CAEemH2fh2goOS7WuRUaVBEN2SSBX0LOv=+LGZwkpjAebS6MFuQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <73fbe83d-97d8-c05f-38fa-5e1a0eec3c10@suse.cz>
Date: Wed, 17 Apr 2019 10:54:38 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAEemH2fh2goOS7WuRUaVBEN2SSBX0LOv=+LGZwkpjAebS6MFuQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/17/19 10:35 AM, Li Wang wrote:
> Hi there,
> 
> I catched this warning on v5.1-rc5(s390x). It was trggiered in fork & malloc & memset stress test, but the reproduced rate is very low. I'm working on find a stable reproducer for it. 
> 
> Anyone can have a look first?
> 
> [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_irect_compact+0x182/0x190

This means compaction was either skipped or deferred, yet it captured a
page. We have some registers with value 1 and 2, which is
COMPACT_SKIPPED and COMPACT_DEFERRED, so it could be one of those.
Probably COMPACT_SKIPPED. I think a race is possible:

- compact_zone_order() sets up current->capture_control
- compact_zone() calls compaction_suitable() which returns
COMPACT_SKIPPED, so it also returns
- interrupt comes and its processing happens to free a page that forms
high-order page, since 'current' isn't changed during interrupt (IIRC?)
the capture_control is still active and the page is captured
- compact_zone_order() does *capture = capc.page

What do you think, Mel, does it look plausible? Not sure whether we want
to try avoiding this scenario, or just remove the warning and be
grateful for the successful capture :)

> [ 1422.124065] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver 
>  nfs lockd grace fscache sunrpc pkey ghash_s390 prng xts aes_s390 des_s390 des_g 
> eneric sha512_s390 zcrypt_cex4 zcrypt vmur binfmt_misc ip_tables xfs libcrc32c d 
> asd_fba_mod qeth_l2 dasd_eckd_mod dasd_mod qeth qdio lcs ctcm ccwgroup fsm dm_mi 
> rror dm_region_hash dm_log dm_mod                                                
> [ 1422.124086] CPU: 0 PID: 9783 Comm: copy.sh Kdump: loaded Not tainted 5.1.0-rc 5 #1                                                                             
> [ 1422.124089] Hardware name: IBM 2827 H43 400 (z/VM 6.4.0)                      
> [ 1422.124092] Krnl PSW : 0704e00180000000 00000000002779ba (__alloc_pages_direct_compact+0x182/0x190)                                                           
> [ 1422.124096]            R:0 T:1 IO:1 EX:1 Key:0 M:1 W:0 P:0 AS:3 CC:2 PM:0 RI: 0 EA:3                                                                           
> [ 1422.124100] Krnl GPRS: 0000000000000000 000003e00226fc24 000003d081bdf200 000 0000000000001                                                                    
> [ 1422.124103]            000000000027789a 0000000000000000 0000000000000001 000 000000006ee03                                                                    
> [ 1422.124107]            000003e00226fc28 0000000000000cc0 0000000000000240 000 0000000000002                                                                    
> [ 1422.124156]            0000000000400000 0000000000753cb0 000000000027789a 000 003e00226fa28                                                                    
> [ 1422.124163] Krnl Code: 00000000002779ac: e320f0a80002        ltg     %r2,168( %r15)                                                                            
> [ 1422.124163]            00000000002779b2: a784fff4            brc     8,27799a                                                                                  
> [ 1422.124163]           #00000000002779b6: a7f40001            brc     15,2779b 8                                                                                
> [ 1422.124163]           >00000000002779ba: a7290000            lghi    %r2,0    
> [ 1422.124163]            00000000002779be: a7f4fff0            brc     15,27799 e                                                                                
> [ 1422.124163]            00000000002779c2: 0707                bcr     0,%r7    
> [ 1422.124163]            00000000002779c4: 0707                bcr     0,%r7    
> [ 1422.124163]            00000000002779c6: 0707                bcr     0,%r7    
> [ 1422.124194] Call Trace:                                                       
> [ 1422.124196] ([<000000000027789a>] __alloc_pages_direct_compact+0x62/0x190)    
> [ 1422.124198]  [<0000000000278618>] __alloc_pages_nodemask+0x728/0x1148         
> [ 1422.124201]  [<0000000000126bb2>] crst_table_alloc+0x32/0x68                  
> [ 1422.124203]  [<0000000000135888>] mm_init+0x118/0x308                         
> [ 1422.124204]  [<0000000000137e60>] copy_process.part.49+0x1820/0x1d90          
> [ 1422.124205]  [<000000000013865c>] _do_fork+0x114/0x3b8                        
> [ 1422.124206]  [<0000000000138aa4>] __s390x_sys_clone+0x44/0x58                 
> [ 1422.124210]  [<0000000000739a90>] system_call+0x288/0x2a8                     
> [ 1422.124210] Last Breaking-Event-Address:                                      
> [ 1422.124212]  [<00000000002779b6>] __alloc_pages_direct_compact+0x17e/0x190    
> [ 1422.124213] ---[ end trace 36649eaa36968eaa ]---                              
> 
> -- 
> Regards,
> Li Wang

