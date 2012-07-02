Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id BD0426B0071
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 07:16:23 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5F9F23EE0B5
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 20:16:22 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 44FF645DE55
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 20:16:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 22E2C45DE51
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 20:16:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C78F1DB8044
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 20:16:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BA9BC1DB8037
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 20:16:21 +0900 (JST)
Message-ID: <4FF1827A.7060806@jp.fujitsu.com>
Date: Mon, 02 Jul 2012 20:14:02 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/7] Make TestSetPageDirty and dirty page accounting in
 one func
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com> <1340881275-5651-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1340881275-5651-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

(2012/06/28 20:01), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Commit a8e7d49a(Fix race in create_empty_buffers() vs __set_page_dirty_buffers())
> extracts TestSetPageDirty from __set_page_dirty and is far away from
> account_page_dirtied.But it's better to make the two operations in one single
> function to keep modular.So in order to avoid the potential race mentioned in
> commit a8e7d49a, we can hold private_lock until __set_page_dirty completes.
> I guess there's no deadlock between ->private_lock and ->tree_lock by quick look.
> 
> It's a prepare patch for following memcg dirty page accounting patches.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

I think there is no problem with the lock order.

My small concern is the impact on the performance. IIUC, lock contention here can be
seen if multiple threads write to the same file in parallel.
Do you have any numbers before/after the patch ?


Thanks,
-Kmae

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
