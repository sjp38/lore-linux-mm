Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 654E46B0262
	for <linux-mm@kvack.org>; Mon, 23 May 2016 08:07:05 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f75so14826245wmf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 05:07:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v8si43777182wjf.38.2016.05.23.05.07.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 May 2016 05:07:04 -0700 (PDT)
Subject: Re: bpf: use-after-free in array_map_alloc
References: <5713C0AD.3020102@oracle.com>
 <20160417172943.GA83672@ast-mbp.thefacebook.com> <5742F127.6080000@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5742F267.3000309@suse.cz>
Date: Mon, 23 May 2016 14:07:03 +0200
MIME-Version: 1.0
In-Reply-To: <5742F127.6080000@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Sasha Levin <sasha.levin@oracle.com>
Cc: ast@kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Linux-MM layout <linux-mm@kvack.org>

On 05/23/2016 02:01 PM, Vlastimil Babka wrote:
>> if I read the report correctly it's not about bpf, but rather points to
>> the issue inside percpu logic.
>> First __alloc_percpu_gfp() is called, then the memory is freed with
>> free_percpu() which triggers async pcpu_balance_work and then
>> pcpu_extend_area_map is hitting use-after-free.
>> I guess bpf percpu array map is stressing this logic the most.
> 
> I've been staring at it for a while (not knowing the code at all) and
> the first thing that struck me is that pcpu_extend_area_map() is done
> outside of pcpu_lock. So what prevents the chunk from being freed during
> the extend?

Erm to be precise, pcpu_lock is unlocked just before calling
pcpu_extend_area_map(), which relocks it after an allocation, and
assumes the chunk still exists at that point. Unless I'm missing
something, that's an unlocked window where chunk can be destroyed by the
workfn, as the report suggests?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
