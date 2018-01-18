Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF5606B025F
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 09:38:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id v25so18065364pfg.14
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 06:38:13 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w17si6289060pgm.363.2018.01.18.06.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 06:38:12 -0800 (PST)
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <20180118131210.456oyh6fw4scwv53@node.shutemov.name>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <4a6681a7-5ed6-ad9c-5d1d-73f1fcc82f3d@linux.intel.com>
Date: Thu, 18 Jan 2018 06:38:10 -0800
MIME-Version: 1.0
In-Reply-To: <20180118131210.456oyh6fw4scwv53@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, mhocko@kernel.org, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On 01/18/2018 05:12 AM, Kirill A. Shutemov wrote:
> -		if (pte_page(*pvmw->pte) - pvmw->page >=
> -				hpage_nr_pages(pvmw->page)) {

Is ->pte guaranteed to map a page which is within the same section as
pvmw->page?  Otherwise, with sparsemem (non-vmemmap), the pointer
arithmetic won't work.

WARN_ON_ONCE(page_to_section(pvmw->page) !=
	     page_to_section(pte_page(*pvmw->pte));

Will detect that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
