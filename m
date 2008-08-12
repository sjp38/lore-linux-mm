Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m7C0hd9E016967
	for <linux-mm@kvack.org>; Tue, 12 Aug 2008 01:43:39 +0100
Received: from yx-out-2324.google.com (yxb8.prod.google.com [10.190.1.72])
	by zps78.corp.google.com with ESMTP id m7C0hbj5011311
	for <linux-mm@kvack.org>; Mon, 11 Aug 2008 17:43:38 -0700
Received: by yx-out-2324.google.com with SMTP id 8so795214yxb.61
        for <linux-mm@kvack.org>; Mon, 11 Aug 2008 17:43:37 -0700 (PDT)
Message-ID: <6599ad830808111743l58322a46u84f7af3e21467b0b@mail.gmail.com>
Date: Mon, 11 Aug 2008 17:43:37 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm][PATCH 1/2] mm owner fix race between swap and exit
In-Reply-To: <20080811173138.71f5bbe4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080811100719.26336.98302.sendpatchset@balbir-laptop>
	 <20080811100733.26336.31346.sendpatchset@balbir-laptop>
	 <20080811173138.71f5bbe4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Mon, Aug 11, 2008 at 5:31 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>> The fix is to notify the subsystem (via mm_owner_changed callback), if
>> no new owner is found by specifying the new task as NULL.
>
> This patch applies to mainline, 2.6.27-rc2 and even 2.6.26.
>
> Against which kernel/patch is it actually applicable?
>
> (If the answer was "all of the above" then please don't go embedding
> mainline bugfixes in the middle of a -mm-only patch series!)

The main thing this fixes is the memrlimit controller, which is only
in -mm. But there's also a dereference of mm->owner in memcontrol.c -
and I think that needs to be fixed to handle a possible NULL mm->owner
too, since in the case of a swapoff racing with the last user of an mm
exiting, I suspect that the swapoff code could try to pull in a page
that gets charged to the mm after its owner has been set to NULL.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
