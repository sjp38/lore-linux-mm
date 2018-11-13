Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1105D6B0007
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 12:27:09 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id y40-v6so13389641wrd.21
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 09:27:09 -0800 (PST)
Received: from vulcan.natalenko.name (vulcan.natalenko.name. [2001:19f0:6c00:8846:5400:ff:fe0c:dfa0])
        by mx.google.com with ESMTPS id p65-v6si10554376wmp.160.2018.11.13.09.27.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Nov 2018 09:27:06 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Nov 2018 18:27:05 +0100
From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
In-Reply-To: <CAGqmi77Ok0usUt5gfyPMYx22FdgqntSrwiap7=DT81HZuvNm_Q@mail.gmail.com>
References: <d45addefdf05b84af96fb494d52b4ec4@natalenko.name>
 <CAGqmi77Ok0usUt5gfyPMYx22FdgqntSrwiap7=DT81HZuvNm_Q@mail.gmail.com>
Message-ID: <5a9ef9a0c8ed688e1566fc7380915837@natalenko.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <timofey.titovets@synesis.ru>
Cc: linux-doc@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>

On 13.11.2018 18:10, Timofey Titovets wrote:
> You mean try do something, like that right?
> 
> read_lock(&tasklist_lock);
>   <get reference to task>
>   task_lock(task);
> read_unlock(&tasklist_lock);
>     last_pid = task_pid_nr(task);
>     ksm_import_task_vma(task);
>   task_unlock(task);

No, task_lock() uses spin_lock() under the bonnet, so this will be the 
same.

Since the sole reason you have to lock/acquire/get a reference to 
task_struct here is to prevent it from disappearing, I was thinking 
about using get_task_struct(), which just increases atomic 
task_struct.usage value (IOW, takes a reference). I *hope* this will be 
enough to prevent task_struct from disappearing in the meantime.

Someone, correct me if I'm wrong.

-- 
   Oleksandr Natalenko (post-factum)
