Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC763C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 16:29:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B33F20C01
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 16:29:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B33F20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C49BD8E0005; Tue, 26 Feb 2019 11:29:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD20F8E0001; Tue, 26 Feb 2019 11:29:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A73B48E0005; Tue, 26 Feb 2019 11:29:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 394A18E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 11:29:24 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id j13so10149920pll.15
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 08:29:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pj/+5Rh/70BuYxl95RwBCa0h9gzdXQjz950YJAuaRbs=;
        b=jEWSzU+k5GuAClJ+j3oBo5halDjdR7vilX5WFXQ/9UbGDU2yOoHSSuNDmFPH71gANR
         6VcX0qleB1wA+YqWPygvNf5wmqI/NN6U022+fwOcBZe0haTFeiefxqlhHO0DIpPWFwPW
         maLjzWU0CWRug3dI/TUq7tTMVXT66L56swMjgyqA15kab6YqkzVT0y046QyKU/YpXkQ+
         7jVi75zA3FBbAUsnA1HKfeySsmUVPPTYI8Y3nnNHAJH9eb6ixu+NogHkAVK9ZtIEkA6K
         gfkrYVUxtWodNaPTy/zl7oWml1QF9ktBnlU/y/IhelgXkCkYU2BLIniv9hkT+vNO9+J1
         7nvA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZaMtCppsjXud/P26xwrwzX9G8hMjLyHg8YdACj0S8ZzoC9vIK/
	HrLp7WGRk6Dk4R1sAmoqhMqLeAj/Z6Ii2nVrXkl8XXggBiuoF//Ygt01xTPTegr25CEFV38uqvU
	G4Qd9HEh4nQaF3WQXgwmBAlStAx60gdbJ5+KBvBUIJVdxW9/Z+b25zREwf8g+CMsWew==
X-Received: by 2002:a63:545:: with SMTP id 66mr24919332pgf.102.1551198563504;
        Tue, 26 Feb 2019 08:29:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IavjkV0YIQ/Embo135NLF8t/KM/KgH7qyeY0z+7d/rozHKGItM43beWUVEzXky1WwhElFsE
X-Received: by 2002:a63:545:: with SMTP id 66mr24919187pgf.102.1551198561269;
        Tue, 26 Feb 2019 08:29:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551198561; cv=none;
        d=google.com; s=arc-20160816;
        b=pzuKw5XzsPCtLtjZZbj5uPEOnuLpUx4gG14zbqCE9a3RPDWgEN3uZTEz/avD1aNrNs
         xPnTI0Mz4zfWpW+g5BcC4ij5D9mjlNTS77XsIqYcCTM/ruF56Rx1CwVswLnFoR4KyGNf
         gkBx30f323i9OtWRgUnJRdxOKcKRD0+ue/YRffgjkmxSa+CF5HzyEeO+0x8/QwJNnDbi
         8Ssjvt8g2klKdI9ndReVxxJgTRS6hR1fbLc/Dpf2DUyVNyQLLQm8ugIWM/1BUdqsEzXE
         Acx2D4Agrw8ZtHsaUKXfzckxTJwcqIjmaAr1L8hqsMWSLo8m71cUKAZM1zkuD5b/+K7o
         jNbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pj/+5Rh/70BuYxl95RwBCa0h9gzdXQjz950YJAuaRbs=;
        b=Ia/3eopbNdTg4DcNEY0IcbQ6E+ADPbGdSN8Wlc7QDaXLJ8nIxoef0ycodLz53qiNi9
         vhanYjMBbER/IEB9UYeGAAn59L4Af9A9jcCyEvs2dWyaELRMO7VN7btZRWJGMtYks1FE
         sk5I8AI2uJri9N8jqXplv05QOFH7e9QV32ZG4XgLiq7R2Xn3zbWJpWcCwBZcbNWyk4w4
         DqphlwXQ9ow+y/b1q7AbC/1CmP0o0eP+HlZvPU3CBgAgo0UkISpB3M406v//Vf8v2a8x
         yzXWmNdHLSssntGDNqMKBmsPlQWBRulEkKotXYC2U8qvXwG9Mo5k8bNoc/gwAKYYAUnw
         IR2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u18si3919126pgk.440.2019.02.26.08.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 08:29:21 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Feb 2019 08:29:20 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,416,1544515200"; 
   d="gz'50?scan'50,208,50";a="117934466"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga007.jf.intel.com with ESMTP; 26 Feb 2019 08:29:18 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gyfbZ-0007DV-RQ; Wed, 27 Feb 2019 00:29:17 +0800
Date: Wed, 27 Feb 2019 00:28:25 +0800
From: kbuild test robot <lkp@intel.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, mhocko@suse.com,
	linux-mm@kvack.org, shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: Re: [PATCH] mm: compaction: remove unnecessary CONFIG_COMPACTION
Message-ID: <201902270011.AxA9WlmI%fengguang.wu@intel.com>
References: <1551161954-11025-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Content-Disposition: inline
In-Reply-To: <1551161954-11025-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yafang,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on tip/perf/core]
[also build test ERROR on v5.0-rc8 next-20190226]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Yafang-Shao/mm-compaction-remove-unnecessary-CONFIG_COMPACTION/20190226-154127
config: i386-randconfig-b0-02261819 (attached as .config)
compiler: gcc-4.9 (Debian 4.9.4-2) 4.9.4
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All error/warnings (new ones prefixed by >>):

   In file included from include/trace/define_trace.h:96:0,
                    from include/trace/events/compaction.h:355,
                    from mm/compaction.c:46:
   include/trace/events/compaction.h: In function 'trace_raw_output_mm_compaction_end':
>> include/trace/trace_events.h:299:18: error: expected expression before ',' token
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^
   include/trace/trace_events.h:79:9: note: in expansion of macro 'PARAMS'
            PARAMS(print));         \
            ^
   include/trace/events/compaction.h:135:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_compaction_end,
    ^
>> include/trace/events/compaction.h:160:2: note: in expansion of macro 'TP_printk'
     TP_printk("zone_start=0x%lx migrate_pfn=0x%lx free_pfn=0x%lx zone_end=0x%lx, mode=%s status=%s",
     ^
>> include/trace/events/compaction.h:166:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->status, COMPACTION_STATUS))
      ^
   include/trace/events/compaction.h: In function 'trace_raw_output_mm_compaction_suitable_template':
>> include/trace/trace_events.h:299:18: error: expected expression before ',' token
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^
   include/trace/events/compaction.h:218:2: note: in expansion of macro 'TP_printk'
     TP_printk("node=%d zone=%-8s order=%d ret=%s",
     ^
   include/trace/events/compaction.h:222:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->ret, COMPACTION_STATUS))
      ^
>> include/trace/trace_events.h:299:18: warning: missing braces around initializer [-Wmissing-braces]
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^
   include/trace/events/compaction.h:218:2: note: in expansion of macro 'TP_printk'
     TP_printk("node=%d zone=%-8s order=%d ret=%s",
     ^
   include/trace/events/compaction.h:222:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->ret, COMPACTION_STATUS))
      ^
   include/trace/trace_events.h:299:18: warning: (near initialization for 'symbols[0]') [-Wmissing-braces]
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^
   include/trace/events/compaction.h:218:2: note: in expansion of macro 'TP_printk'
     TP_printk("node=%d zone=%-8s order=%d ret=%s",
     ^
   include/trace/events/compaction.h:222:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->ret, COMPACTION_STATUS))
      ^
>> include/trace/trace_events.h:299:18: error: initializer element is not constant
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^
   include/trace/events/compaction.h:218:2: note: in expansion of macro 'TP_printk'
     TP_printk("node=%d zone=%-8s order=%d ret=%s",
     ^
   include/trace/events/compaction.h:222:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->ret, COMPACTION_STATUS))
      ^
   include/trace/trace_events.h:299:18: error: (near initialization for 'symbols[0].mask')
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^
   include/trace/events/compaction.h:218:2: note: in expansion of macro 'TP_printk'
     TP_printk("node=%d zone=%-8s order=%d ret=%s",
     ^
   include/trace/events/compaction.h:222:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->ret, COMPACTION_STATUS))
      ^
   In file included from include/trace/define_trace.h:96:0,
                    from include/trace/events/compaction.h:355,
                    from mm/compaction.c:46:
   include/trace/events/compaction.h: In function 'trace_event_raw_event_mm_compaction_defer_template':
>> include/trace/events/compaction.h:262:29: error: 'struct zone' has no member named 'compact_considered'
      __entry->considered = zone->compact_considered;
                                ^
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^
>> include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^
>> include/trace/events/compaction.h:262:23: warning: assignment makes integer from pointer without a cast
      __entry->considered = zone->compact_considered;
                          ^
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^
>> include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^
   include/trace/events/compaction.h:263:30: error: 'struct zone' has no member named 'compact_defer_shift'
      __entry->defer_shift = zone->compact_defer_shift;
                                 ^
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^
>> include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^
   include/trace/events/compaction.h:263:24: warning: assignment makes integer from pointer without a cast
      __entry->defer_shift = zone->compact_defer_shift;
                           ^
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^
>> include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^
   include/trace/events/compaction.h:264:31: error: 'struct zone' has no member named 'compact_order_failed'
      __entry->order_failed = zone->compact_order_failed;
                                  ^
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^
>> include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^
   include/trace/events/compaction.h:264:25: warning: assignment makes integer from pointer without a cast
      __entry->order_failed = zone->compact_order_failed;
                            ^
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^
>> include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^
   In file included from include/trace/define_trace.h:97:0,
                    from include/trace/events/compaction.h:355,
                    from mm/compaction.c:46:
   include/trace/events/compaction.h: In function 'perf_trace_mm_compaction_defer_template':
>> include/trace/events/compaction.h:262:29: error: 'struct zone' has no member named 'compact_considered'
      __entry->considered = zone->compact_considered;
                                ^
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^
>> include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^
>> include/trace/events/compaction.h:262:23: warning: assignment makes integer from pointer without a cast
      __entry->considered = zone->compact_considered;
                          ^
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^
>> include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^
   include/trace/events/compaction.h:263:30: error: 'struct zone' has no member named 'compact_defer_shift'
      __entry->defer_shift = zone->compact_defer_shift;
                                 ^
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^
>> include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^
   include/trace/events/compaction.h:263:24: warning: assignment makes integer from pointer without a cast
      __entry->defer_shift = zone->compact_defer_shift;
                           ^
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^
>> include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^
   include/trace/events/compaction.h:264:31: error: 'struct zone' has no member named 'compact_order_failed'
      __entry->order_failed = zone->compact_order_failed;
                                  ^
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^

vim +262 include/trace/events/compaction.h

0eb927c0a Mel Gorman      2014-01-21  134  
0eb927c0a Mel Gorman      2014-01-21 @135  TRACE_EVENT(mm_compaction_end,
16c4a097a Joonsoo Kim     2015-02-11  136  	TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
16c4a097a Joonsoo Kim     2015-02-11  137  		unsigned long free_pfn, unsigned long zone_end, bool sync,
16c4a097a Joonsoo Kim     2015-02-11  138  		int status),
0eb927c0a Mel Gorman      2014-01-21  139  
16c4a097a Joonsoo Kim     2015-02-11  140  	TP_ARGS(zone_start, migrate_pfn, free_pfn, zone_end, sync, status),
0eb927c0a Mel Gorman      2014-01-21  141  
0eb927c0a Mel Gorman      2014-01-21  142  	TP_STRUCT__entry(
16c4a097a Joonsoo Kim     2015-02-11  143  		__field(unsigned long, zone_start)
16c4a097a Joonsoo Kim     2015-02-11  144  		__field(unsigned long, migrate_pfn)
16c4a097a Joonsoo Kim     2015-02-11  145  		__field(unsigned long, free_pfn)
16c4a097a Joonsoo Kim     2015-02-11  146  		__field(unsigned long, zone_end)
16c4a097a Joonsoo Kim     2015-02-11  147  		__field(bool, sync)
0eb927c0a Mel Gorman      2014-01-21  148  		__field(int, status)
0eb927c0a Mel Gorman      2014-01-21  149  	),
0eb927c0a Mel Gorman      2014-01-21  150  
0eb927c0a Mel Gorman      2014-01-21  151  	TP_fast_assign(
16c4a097a Joonsoo Kim     2015-02-11  152  		__entry->zone_start = zone_start;
16c4a097a Joonsoo Kim     2015-02-11  153  		__entry->migrate_pfn = migrate_pfn;
16c4a097a Joonsoo Kim     2015-02-11  154  		__entry->free_pfn = free_pfn;
16c4a097a Joonsoo Kim     2015-02-11  155  		__entry->zone_end = zone_end;
16c4a097a Joonsoo Kim     2015-02-11  156  		__entry->sync = sync;
0eb927c0a Mel Gorman      2014-01-21  157  		__entry->status = status;
0eb927c0a Mel Gorman      2014-01-21  158  	),
0eb927c0a Mel Gorman      2014-01-21  159  
16c4a097a Joonsoo Kim     2015-02-11 @160  	TP_printk("zone_start=0x%lx migrate_pfn=0x%lx free_pfn=0x%lx zone_end=0x%lx, mode=%s status=%s",
16c4a097a Joonsoo Kim     2015-02-11  161  		__entry->zone_start,
16c4a097a Joonsoo Kim     2015-02-11  162  		__entry->migrate_pfn,
16c4a097a Joonsoo Kim     2015-02-11  163  		__entry->free_pfn,
16c4a097a Joonsoo Kim     2015-02-11  164  		__entry->zone_end,
16c4a097a Joonsoo Kim     2015-02-11  165  		__entry->sync ? "sync" : "async",
fa6c7b46a Vlastimil Babka 2015-11-05 @166  		__print_symbolic(__entry->status, COMPACTION_STATUS))
0eb927c0a Mel Gorman      2014-01-21  167  );
b7aba6984 Mel Gorman      2011-01-13  168  
837d026d5 Joonsoo Kim     2015-02-11  169  TRACE_EVENT(mm_compaction_try_to_compact_pages,
837d026d5 Joonsoo Kim     2015-02-11  170  
837d026d5 Joonsoo Kim     2015-02-11  171  	TP_PROTO(
837d026d5 Joonsoo Kim     2015-02-11  172  		int order,
837d026d5 Joonsoo Kim     2015-02-11  173  		gfp_t gfp_mask,
a5508cd83 Vlastimil Babka 2016-07-28  174  		int prio),
837d026d5 Joonsoo Kim     2015-02-11  175  
a5508cd83 Vlastimil Babka 2016-07-28  176  	TP_ARGS(order, gfp_mask, prio),
837d026d5 Joonsoo Kim     2015-02-11  177  
837d026d5 Joonsoo Kim     2015-02-11  178  	TP_STRUCT__entry(
837d026d5 Joonsoo Kim     2015-02-11  179  		__field(int, order)
837d026d5 Joonsoo Kim     2015-02-11  180  		__field(gfp_t, gfp_mask)
a5508cd83 Vlastimil Babka 2016-07-28  181  		__field(int, prio)
837d026d5 Joonsoo Kim     2015-02-11  182  	),
837d026d5 Joonsoo Kim     2015-02-11  183  
837d026d5 Joonsoo Kim     2015-02-11  184  	TP_fast_assign(
837d026d5 Joonsoo Kim     2015-02-11  185  		__entry->order = order;
837d026d5 Joonsoo Kim     2015-02-11  186  		__entry->gfp_mask = gfp_mask;
a5508cd83 Vlastimil Babka 2016-07-28  187  		__entry->prio = prio;
837d026d5 Joonsoo Kim     2015-02-11  188  	),
837d026d5 Joonsoo Kim     2015-02-11  189  
a5508cd83 Vlastimil Babka 2016-07-28  190  	TP_printk("order=%d gfp_mask=0x%x priority=%d",
837d026d5 Joonsoo Kim     2015-02-11  191  		__entry->order,
837d026d5 Joonsoo Kim     2015-02-11  192  		__entry->gfp_mask,
a5508cd83 Vlastimil Babka 2016-07-28  193  		__entry->prio)
837d026d5 Joonsoo Kim     2015-02-11  194  );
837d026d5 Joonsoo Kim     2015-02-11  195  
837d026d5 Joonsoo Kim     2015-02-11  196  DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
837d026d5 Joonsoo Kim     2015-02-11  197  
837d026d5 Joonsoo Kim     2015-02-11  198  	TP_PROTO(struct zone *zone,
837d026d5 Joonsoo Kim     2015-02-11  199  		int order,
837d026d5 Joonsoo Kim     2015-02-11  200  		int ret),
837d026d5 Joonsoo Kim     2015-02-11  201  
837d026d5 Joonsoo Kim     2015-02-11  202  	TP_ARGS(zone, order, ret),
837d026d5 Joonsoo Kim     2015-02-11  203  
837d026d5 Joonsoo Kim     2015-02-11  204  	TP_STRUCT__entry(
837d026d5 Joonsoo Kim     2015-02-11  205  		__field(int, nid)
1743d0506 Vlastimil Babka 2015-11-05  206  		__field(enum zone_type, idx)
837d026d5 Joonsoo Kim     2015-02-11  207  		__field(int, order)
837d026d5 Joonsoo Kim     2015-02-11  208  		__field(int, ret)
837d026d5 Joonsoo Kim     2015-02-11  209  	),
837d026d5 Joonsoo Kim     2015-02-11  210  
837d026d5 Joonsoo Kim     2015-02-11  211  	TP_fast_assign(
837d026d5 Joonsoo Kim     2015-02-11  212  		__entry->nid = zone_to_nid(zone);
1743d0506 Vlastimil Babka 2015-11-05  213  		__entry->idx = zone_idx(zone);
837d026d5 Joonsoo Kim     2015-02-11  214  		__entry->order = order;
837d026d5 Joonsoo Kim     2015-02-11  215  		__entry->ret = ret;
837d026d5 Joonsoo Kim     2015-02-11  216  	),
837d026d5 Joonsoo Kim     2015-02-11  217  
837d026d5 Joonsoo Kim     2015-02-11  218  	TP_printk("node=%d zone=%-8s order=%d ret=%s",
837d026d5 Joonsoo Kim     2015-02-11  219  		__entry->nid,
1743d0506 Vlastimil Babka 2015-11-05  220  		__print_symbolic(__entry->idx, ZONE_TYPE),
837d026d5 Joonsoo Kim     2015-02-11  221  		__entry->order,
fa6c7b46a Vlastimil Babka 2015-11-05 @222  		__print_symbolic(__entry->ret, COMPACTION_STATUS))
837d026d5 Joonsoo Kim     2015-02-11  223  );
837d026d5 Joonsoo Kim     2015-02-11  224  
837d026d5 Joonsoo Kim     2015-02-11  225  DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_finished,
837d026d5 Joonsoo Kim     2015-02-11  226  
837d026d5 Joonsoo Kim     2015-02-11  227  	TP_PROTO(struct zone *zone,
837d026d5 Joonsoo Kim     2015-02-11  228  		int order,
837d026d5 Joonsoo Kim     2015-02-11  229  		int ret),
837d026d5 Joonsoo Kim     2015-02-11  230  
837d026d5 Joonsoo Kim     2015-02-11  231  	TP_ARGS(zone, order, ret)
837d026d5 Joonsoo Kim     2015-02-11  232  );
837d026d5 Joonsoo Kim     2015-02-11  233  
837d026d5 Joonsoo Kim     2015-02-11  234  DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
837d026d5 Joonsoo Kim     2015-02-11  235  
837d026d5 Joonsoo Kim     2015-02-11  236  	TP_PROTO(struct zone *zone,
837d026d5 Joonsoo Kim     2015-02-11  237  		int order,
837d026d5 Joonsoo Kim     2015-02-11  238  		int ret),
837d026d5 Joonsoo Kim     2015-02-11  239  
837d026d5 Joonsoo Kim     2015-02-11  240  	TP_ARGS(zone, order, ret)
837d026d5 Joonsoo Kim     2015-02-11  241  );
837d026d5 Joonsoo Kim     2015-02-11  242  
24e2716f6 Joonsoo Kim     2015-02-11  243  DECLARE_EVENT_CLASS(mm_compaction_defer_template,
24e2716f6 Joonsoo Kim     2015-02-11  244  
24e2716f6 Joonsoo Kim     2015-02-11  245  	TP_PROTO(struct zone *zone, int order),
24e2716f6 Joonsoo Kim     2015-02-11  246  
24e2716f6 Joonsoo Kim     2015-02-11  247  	TP_ARGS(zone, order),
24e2716f6 Joonsoo Kim     2015-02-11  248  
24e2716f6 Joonsoo Kim     2015-02-11  249  	TP_STRUCT__entry(
24e2716f6 Joonsoo Kim     2015-02-11  250  		__field(int, nid)
1743d0506 Vlastimil Babka 2015-11-05  251  		__field(enum zone_type, idx)
24e2716f6 Joonsoo Kim     2015-02-11  252  		__field(int, order)
24e2716f6 Joonsoo Kim     2015-02-11  253  		__field(unsigned int, considered)
24e2716f6 Joonsoo Kim     2015-02-11  254  		__field(unsigned int, defer_shift)
24e2716f6 Joonsoo Kim     2015-02-11  255  		__field(int, order_failed)
24e2716f6 Joonsoo Kim     2015-02-11  256  	),
24e2716f6 Joonsoo Kim     2015-02-11  257  
24e2716f6 Joonsoo Kim     2015-02-11 @258  	TP_fast_assign(
24e2716f6 Joonsoo Kim     2015-02-11  259  		__entry->nid = zone_to_nid(zone);
1743d0506 Vlastimil Babka 2015-11-05  260  		__entry->idx = zone_idx(zone);
24e2716f6 Joonsoo Kim     2015-02-11  261  		__entry->order = order;
24e2716f6 Joonsoo Kim     2015-02-11 @262  		__entry->considered = zone->compact_considered;
24e2716f6 Joonsoo Kim     2015-02-11  263  		__entry->defer_shift = zone->compact_defer_shift;
24e2716f6 Joonsoo Kim     2015-02-11  264  		__entry->order_failed = zone->compact_order_failed;
24e2716f6 Joonsoo Kim     2015-02-11  265  	),
24e2716f6 Joonsoo Kim     2015-02-11  266  
24e2716f6 Joonsoo Kim     2015-02-11  267  	TP_printk("node=%d zone=%-8s order=%d order_failed=%d consider=%u limit=%lu",
24e2716f6 Joonsoo Kim     2015-02-11  268  		__entry->nid,
1743d0506 Vlastimil Babka 2015-11-05  269  		__print_symbolic(__entry->idx, ZONE_TYPE),
24e2716f6 Joonsoo Kim     2015-02-11  270  		__entry->order,
24e2716f6 Joonsoo Kim     2015-02-11  271  		__entry->order_failed,
24e2716f6 Joonsoo Kim     2015-02-11  272  		__entry->considered,
24e2716f6 Joonsoo Kim     2015-02-11  273  		1UL << __entry->defer_shift)
24e2716f6 Joonsoo Kim     2015-02-11  274  );
24e2716f6 Joonsoo Kim     2015-02-11  275  
24e2716f6 Joonsoo Kim     2015-02-11  276  DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_deferred,
24e2716f6 Joonsoo Kim     2015-02-11  277  
24e2716f6 Joonsoo Kim     2015-02-11  278  	TP_PROTO(struct zone *zone, int order),
24e2716f6 Joonsoo Kim     2015-02-11  279  
24e2716f6 Joonsoo Kim     2015-02-11  280  	TP_ARGS(zone, order)
24e2716f6 Joonsoo Kim     2015-02-11  281  );
24e2716f6 Joonsoo Kim     2015-02-11  282  
24e2716f6 Joonsoo Kim     2015-02-11  283  DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_compaction,
24e2716f6 Joonsoo Kim     2015-02-11  284  
24e2716f6 Joonsoo Kim     2015-02-11  285  	TP_PROTO(struct zone *zone, int order),
24e2716f6 Joonsoo Kim     2015-02-11  286  
24e2716f6 Joonsoo Kim     2015-02-11  287  	TP_ARGS(zone, order)
24e2716f6 Joonsoo Kim     2015-02-11  288  );
24e2716f6 Joonsoo Kim     2015-02-11  289  
24e2716f6 Joonsoo Kim     2015-02-11  290  DEFINE_EVENT(mm_compaction_defer_template, mm_compaction_defer_reset,
24e2716f6 Joonsoo Kim     2015-02-11  291  
24e2716f6 Joonsoo Kim     2015-02-11  292  	TP_PROTO(struct zone *zone, int order),
24e2716f6 Joonsoo Kim     2015-02-11  293  
24e2716f6 Joonsoo Kim     2015-02-11  294  	TP_ARGS(zone, order)
24e2716f6 Joonsoo Kim     2015-02-11  295  );
24e2716f6 Joonsoo Kim     2015-02-11  296  
698b1b306 Vlastimil Babka 2016-03-17  297  TRACE_EVENT(mm_compaction_kcompactd_sleep,
698b1b306 Vlastimil Babka 2016-03-17  298  
698b1b306 Vlastimil Babka 2016-03-17  299  	TP_PROTO(int nid),
698b1b306 Vlastimil Babka 2016-03-17  300  
698b1b306 Vlastimil Babka 2016-03-17  301  	TP_ARGS(nid),
698b1b306 Vlastimil Babka 2016-03-17  302  
698b1b306 Vlastimil Babka 2016-03-17  303  	TP_STRUCT__entry(
698b1b306 Vlastimil Babka 2016-03-17  304  		__field(int, nid)
698b1b306 Vlastimil Babka 2016-03-17  305  	),
698b1b306 Vlastimil Babka 2016-03-17  306  
698b1b306 Vlastimil Babka 2016-03-17  307  	TP_fast_assign(
698b1b306 Vlastimil Babka 2016-03-17  308  		__entry->nid = nid;
698b1b306 Vlastimil Babka 2016-03-17  309  	),
698b1b306 Vlastimil Babka 2016-03-17  310  
698b1b306 Vlastimil Babka 2016-03-17  311  	TP_printk("nid=%d", __entry->nid)
698b1b306 Vlastimil Babka 2016-03-17  312  );
698b1b306 Vlastimil Babka 2016-03-17  313  
698b1b306 Vlastimil Babka 2016-03-17  314  DECLARE_EVENT_CLASS(kcompactd_wake_template,
698b1b306 Vlastimil Babka 2016-03-17  315  
698b1b306 Vlastimil Babka 2016-03-17  316  	TP_PROTO(int nid, int order, enum zone_type classzone_idx),
698b1b306 Vlastimil Babka 2016-03-17  317  
698b1b306 Vlastimil Babka 2016-03-17  318  	TP_ARGS(nid, order, classzone_idx),
698b1b306 Vlastimil Babka 2016-03-17  319  
698b1b306 Vlastimil Babka 2016-03-17  320  	TP_STRUCT__entry(
698b1b306 Vlastimil Babka 2016-03-17  321  		__field(int, nid)
698b1b306 Vlastimil Babka 2016-03-17  322  		__field(int, order)
698b1b306 Vlastimil Babka 2016-03-17  323  		__field(enum zone_type, classzone_idx)
698b1b306 Vlastimil Babka 2016-03-17  324  	),
698b1b306 Vlastimil Babka 2016-03-17  325  
698b1b306 Vlastimil Babka 2016-03-17  326  	TP_fast_assign(
698b1b306 Vlastimil Babka 2016-03-17  327  		__entry->nid = nid;
698b1b306 Vlastimil Babka 2016-03-17  328  		__entry->order = order;
698b1b306 Vlastimil Babka 2016-03-17  329  		__entry->classzone_idx = classzone_idx;
698b1b306 Vlastimil Babka 2016-03-17  330  	),
698b1b306 Vlastimil Babka 2016-03-17  331  
698b1b306 Vlastimil Babka 2016-03-17  332  	TP_printk("nid=%d order=%d classzone_idx=%-8s",
698b1b306 Vlastimil Babka 2016-03-17  333  		__entry->nid,
698b1b306 Vlastimil Babka 2016-03-17  334  		__entry->order,
698b1b306 Vlastimil Babka 2016-03-17  335  		__print_symbolic(__entry->classzone_idx, ZONE_TYPE))
698b1b306 Vlastimil Babka 2016-03-17  336  );
698b1b306 Vlastimil Babka 2016-03-17  337  
698b1b306 Vlastimil Babka 2016-03-17  338  DEFINE_EVENT(kcompactd_wake_template, mm_compaction_wakeup_kcompactd,
698b1b306 Vlastimil Babka 2016-03-17  339  
698b1b306 Vlastimil Babka 2016-03-17  340  	TP_PROTO(int nid, int order, enum zone_type classzone_idx),
698b1b306 Vlastimil Babka 2016-03-17  341  
698b1b306 Vlastimil Babka 2016-03-17  342  	TP_ARGS(nid, order, classzone_idx)
698b1b306 Vlastimil Babka 2016-03-17  343  );
698b1b306 Vlastimil Babka 2016-03-17  344  
698b1b306 Vlastimil Babka 2016-03-17  345  DEFINE_EVENT(kcompactd_wake_template, mm_compaction_kcompactd_wake,
698b1b306 Vlastimil Babka 2016-03-17  346  
698b1b306 Vlastimil Babka 2016-03-17  347  	TP_PROTO(int nid, int order, enum zone_type classzone_idx),
698b1b306 Vlastimil Babka 2016-03-17  348  
698b1b306 Vlastimil Babka 2016-03-17  349  	TP_ARGS(nid, order, classzone_idx)
698b1b306 Vlastimil Babka 2016-03-17  350  );
698b1b306 Vlastimil Babka 2016-03-17  351  
b7aba6984 Mel Gorman      2011-01-13  352  #endif /* _TRACE_COMPACTION_H */
b7aba6984 Mel Gorman      2011-01-13  353  
b7aba6984 Mel Gorman      2011-01-13  354  /* This part must be outside protection */
b7aba6984 Mel Gorman      2011-01-13 @355  #include <trace/define_trace.h>

:::::: The code at line 262 was first introduced by commit
:::::: 24e2716f63e613cf15d3beba3faa0711bcacc427 mm/compaction: add tracepoint to observe behaviour of compaction defer

:::::: TO: Joonsoo Kim <iamjoonsoo.kim@lge.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--opJtzjQTFsWo+cga
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--opJtzjQTFsWo+cga--

