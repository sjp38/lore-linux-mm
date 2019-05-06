Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E457AC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 18:04:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB67220675
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 18:04:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB67220675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DEC26B026E; Mon,  6 May 2019 14:04:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 48F466B026F; Mon,  6 May 2019 14:04:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 357E76B0272; Mon,  6 May 2019 14:04:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id F02476B026E
	for <linux-mm@kvack.org>; Mon,  6 May 2019 14:04:08 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e12so8490829pgh.2
        for <linux-mm@kvack.org>; Mon, 06 May 2019 11:04:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ZE8OcrNvQBPlvEaMsC/KVbn2fVAkN5WlDMVPI58SIJ0=;
        b=ihtMeDSw3FAYJn3wOIoSgzEqmYdUhq0hlW1zNXUHA83l3ookuxGEeAs2D5qyqC+jFB
         EUKdFBtNmLbgGxVoDRTyRWrC3RB7q9DthI3jAz1LZOh12T9S4YYN4y4lhFMvLNknlIEP
         o7gRj7VeJuXBt8ky+M1uwVmmeFsCTqFtl53Y120bSU7tvPRGj6jGNW4PfJppDzcssX8F
         GbXXWnEgfN6sULJn0/qJKCuUYnawlcIg2QywK/qPk1UEtGmyYtBLKLYj0HPfSx2vTrAS
         TOZcT2jFOLvbjzTplh+gloYx6N+PXrxqx9SbO3H6DCE+OTO77TdZpdNYsjs2VoOfR2gZ
         TKmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUMvOtLOqi3js2Z4Qgz3ebDSN3io2JUsrXz9I78P2Bs0OlQgZu9
	fVv73xJFS1MD0+4Guw3CQiW5YK/1oJn+gylS3OxHM8naJBwOoycxyaIL9NhLZl481eL/OSBYJoC
	ifJUaoH+wW5Jtwd9Qfrwqe2FrmF45WaVnfimWzp1ZYWmA4JrcJlHBrM2W3hcIPHm/Ww==
X-Received: by 2002:a63:564f:: with SMTP id g15mr34254320pgm.258.1557165848667;
        Mon, 06 May 2019 11:04:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysdigwu3oFK+39OZtnKp3xi/5ZWF38WTJdDLL3tObhCF6+S3Qc1Vw8B/YUVAQKU7Xo75jK
X-Received: by 2002:a63:564f:: with SMTP id g15mr34254249pgm.258.1557165848144;
        Mon, 06 May 2019 11:04:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557165848; cv=none;
        d=google.com; s=arc-20160816;
        b=CP7zGrErAEXyZTc21jI5tCcw2Kser7U1iEYIqeIspEXv7ltLvWpOpBoG6FHmaN1T8n
         Ll/pVCarZCTV3QOotTpazEE91gOhsEBRyeFEyYSdUw7MOnhCFZS471g7GFMVAs6KxTGA
         haEvpB5YDtSMz2Q0iHqZndUuD3p5a6NAprH927hbjcBPqK5/EHwJFShZrmtA699LJ2t3
         MEBMLFEyG/dEIznPNaQ2P2buME0rZDHb0ITaiFbtD+zwT9M69cFnCOG2VK8nWxmZc+Pd
         vfqN7F7Nkg+ck3uq/xmM9EIAEa9XXMKaxq7n7uohRQiOU530BTiVK6uzP1SD4l4KHu6T
         pfYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=ZE8OcrNvQBPlvEaMsC/KVbn2fVAkN5WlDMVPI58SIJ0=;
        b=trmSXr8eHqLbB6gaBF4f0LGBCTMAq+MtYX6a8TlHRaBBMkk1mpV+Ksm9zGE2RI4VFK
         j+3E1+iqUHxu+Yx+IHNlsYV/JvLx7yCaJjFnzGegexeJoSxsd5uFUrsrqcmwFO9su2Xh
         c3s+it/xY912QsW5h6uzGcYDn3i0nh9W/nHymKB7DFo3MVxn3rW2ZXuMJ7w26PVTBDBw
         mwsduEhcSNanEgFzcbhN1DjTJK39fnjPuTmqnwfCOrJrgpjeALVDOV8FhRIDwibglimi
         VgD8KpW/ia5k6zptfadAtvnAn9leh//3aPNxKmeQ7flyLSCXno2M5osYRyXst5qQhEBY
         imSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b3si17110856plc.106.2019.05.06.11.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 11:04:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 May 2019 11:04:01 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga002.jf.intel.com with ESMTP; 06 May 2019 11:04:01 -0700
Subject: Re: [v5 2/3] mm/hotplug: make remove_memory() interface useable
To: Dan Williams <dan.j.williams@intel.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>,
 James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Keith Busch <keith.busch@intel.com>,
 Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang
 <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>,
 Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying"
 <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>,
 Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>,
 Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 David Hildenbrand <david@redhat.com>
References: <20190502184337.20538-1-pasha.tatashin@soleen.com>
 <20190502184337.20538-3-pasha.tatashin@soleen.com>
 <cac721ed-c404-19d1-71d1-37c66df9b2a8@intel.com>
 <CAPcyv4greisKBSorzQWebcVOf2AqUH6DwbvNKMW0MQ5bCwYZrw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 mQINBE6HMP0BEADIMA3XYkQfF3dwHlj58Yjsc4E5y5G67cfbt8dvaUq2fx1lR0K9h1bOI6fC
 oAiUXvGAOxPDsB/P6UEOISPpLl5IuYsSwAeZGkdQ5g6m1xq7AlDJQZddhr/1DC/nMVa/2BoY
 2UnKuZuSBu7lgOE193+7Uks3416N2hTkyKUSNkduyoZ9F5twiBhxPJwPtn/wnch6n5RsoXsb
 ygOEDxLEsSk/7eyFycjE+btUtAWZtx+HseyaGfqkZK0Z9bT1lsaHecmB203xShwCPT49Blxz
 VOab8668QpaEOdLGhtvrVYVK7x4skyT3nGWcgDCl5/Vp3TWA4K+IofwvXzX2ON/Mj7aQwf5W
 iC+3nWC7q0uxKwwsddJ0Nu+dpA/UORQWa1NiAftEoSpk5+nUUi0WE+5DRm0H+TXKBWMGNCFn
 c6+EKg5zQaa8KqymHcOrSXNPmzJuXvDQ8uj2J8XuzCZfK4uy1+YdIr0yyEMI7mdh4KX50LO1
 pmowEqDh7dLShTOif/7UtQYrzYq9cPnjU2ZW4qd5Qz2joSGTG9eCXLz5PRe5SqHxv6ljk8mb
 ApNuY7bOXO/A7T2j5RwXIlcmssqIjBcxsRRoIbpCwWWGjkYjzYCjgsNFL6rt4OL11OUF37wL
 QcTl7fbCGv53KfKPdYD5hcbguLKi/aCccJK18ZwNjFhqr4MliQARAQABtEVEYXZpZCBDaHJp
 c3RvcGhlciBIYW5zZW4gKEludGVsIFdvcmsgQWRkcmVzcykgPGRhdmUuaGFuc2VuQGludGVs
 LmNvbT6JAjgEEwECACIFAlQ+9J0CGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEGg1
 lTBwyZKwLZUP/0dnbhDc229u2u6WtK1s1cSd9WsflGXGagkR6liJ4um3XCfYWDHvIdkHYC1t
 MNcVHFBwmQkawxsYvgO8kXT3SaFZe4ISfB4K4CL2qp4JO+nJdlFUbZI7cz/Td9z8nHjMcWYF
 IQuTsWOLs/LBMTs+ANumibtw6UkiGVD3dfHJAOPNApjVr+M0P/lVmTeP8w0uVcd2syiaU5jB
 aht9CYATn+ytFGWZnBEEQFnqcibIaOrmoBLu2b3fKJEd8Jp7NHDSIdrvrMjYynmc6sZKUqH2
 I1qOevaa8jUg7wlLJAWGfIqnu85kkqrVOkbNbk4TPub7VOqA6qG5GCNEIv6ZY7HLYd/vAkVY
 E8Plzq/NwLAuOWxvGrOl7OPuwVeR4hBDfcrNb990MFPpjGgACzAZyjdmYoMu8j3/MAEW4P0z
 F5+EYJAOZ+z212y1pchNNauehORXgjrNKsZwxwKpPY9qb84E3O9KYpwfATsqOoQ6tTgr+1BR
 CCwP712H+E9U5HJ0iibN/CDZFVPL1bRerHziuwuQuvE0qWg0+0SChFe9oq0KAwEkVs6ZDMB2
 P16MieEEQ6StQRlvy2YBv80L1TMl3T90Bo1UUn6ARXEpcbFE0/aORH/jEXcRteb+vuik5UGY
 5TsyLYdPur3TXm7XDBdmmyQVJjnJKYK9AQxj95KlXLVO38lcuQINBFRjzmoBEACyAxbvUEhd
 GDGNg0JhDdezyTdN8C9BFsdxyTLnSH31NRiyp1QtuxvcqGZjb2trDVuCbIzRrgMZLVgo3upr
 MIOx1CXEgmn23Zhh0EpdVHM8IKx9Z7V0r+rrpRWFE8/wQZngKYVi49PGoZj50ZEifEJ5qn/H
 Nsp2+Y+bTUjDdgWMATg9DiFMyv8fvoqgNsNyrrZTnSgoLzdxr89FGHZCoSoAK8gfgFHuO54B
 lI8QOfPDG9WDPJ66HCodjTlBEr/Cwq6GruxS5i2Y33YVqxvFvDa1tUtl+iJ2SWKS9kCai2DR
 3BwVONJEYSDQaven/EHMlY1q8Vln3lGPsS11vSUK3QcNJjmrgYxH5KsVsf6PNRj9mp8Z1kIG
 qjRx08+nnyStWC0gZH6NrYyS9rpqH3j+hA2WcI7De51L4Rv9pFwzp161mvtc6eC/GxaiUGuH
 BNAVP0PY0fqvIC68p3rLIAW3f97uv4ce2RSQ7LbsPsimOeCo/5vgS6YQsj83E+AipPr09Caj
 0hloj+hFoqiticNpmsxdWKoOsV0PftcQvBCCYuhKbZV9s5hjt9qn8CE86A5g5KqDf83Fxqm/
 vXKgHNFHE5zgXGZnrmaf6resQzbvJHO0Fb0CcIohzrpPaL3YepcLDoCCgElGMGQjdCcSQ+Ci
 FCRl0Bvyj1YZUql+ZkptgGjikQARAQABiQIfBBgBAgAJBQJUY85qAhsMAAoJEGg1lTBwyZKw
 l4IQAIKHs/9po4spZDFyfDjunimEhVHqlUt7ggR1Hsl/tkvTSze8pI1P6dGp2XW6AnH1iayn
 yRcoyT0ZJ+Zmm4xAH1zqKjWplzqdb/dO28qk0bPso8+1oPO8oDhLm1+tY+cOvufXkBTm+whm
 +AyNTjaCRt6aSMnA/QHVGSJ8grrTJCoACVNhnXg/R0g90g8iV8Q+IBZyDkG0tBThaDdw1B2l
 asInUTeb9EiVfL/Zjdg5VWiF9LL7iS+9hTeVdR09vThQ/DhVbCNxVk+DtyBHsjOKifrVsYep
 WpRGBIAu3bK8eXtyvrw1igWTNs2wazJ71+0z2jMzbclKAyRHKU9JdN6Hkkgr2nPb561yjcB8
 sIq1pFXKyO+nKy6SZYxOvHxCcjk2fkw6UmPU6/j/nQlj2lfOAgNVKuDLothIxzi8pndB8Jju
 KktE5HJqUUMXePkAYIxEQ0mMc8Po7tuXdejgPMwgP7x65xtfEqI0RuzbUioFltsp1jUaRwQZ
 MTsCeQDdjpgHsj+P2ZDeEKCbma4m6Ez/YWs4+zDm1X8uZDkZcfQlD9NldbKDJEXLIjYWo1PH
 hYepSffIWPyvBMBTW2W5FRjJ4vLRrJSUoEfJuPQ3vW9Y73foyo/qFoURHO48AinGPZ7PC7TF
 vUaNOTjKedrqHkaOcqB185ahG2had0xnFsDPlx5y
Message-ID: <cf793443-c14a-a1e0-856e-15e416c7f874@intel.com>
Date: Mon, 6 May 2019 11:04:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4greisKBSorzQWebcVOf2AqUH6DwbvNKMW0MQ5bCwYZrw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/6/19 11:01 AM, Dan Williams wrote:
>>> +void __remove_memory(int nid, u64 start, u64 size)
>>>  {
>>> +
>>> +     /*
>>> +      * trigger BUG() is some memory is not offlined prior to calling this
>>> +      * function
>>> +      */
>>> +     if (try_remove_memory(nid, start, size))
>>> +             BUG();
>>> +}
>> Could we call this remove_offline_memory()?  That way, it makes _some_
>> sense why we would BUG() if the memory isn't offline.
> Please WARN() instead of BUG() because failing to remove memory should
> not be system fatal.

That is my preference as well.  But, the existing code BUG()s, so I'm
OK-ish with this staying for the moment until we have a better handle on
what all the callers do if this fails.

