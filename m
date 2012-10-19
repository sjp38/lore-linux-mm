Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id A47796B007D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 03:01:33 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so169064oag.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2012 00:01:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350629202-9664-4-git-send-email-wency@cn.fujitsu.com>
References: <1350629202-9664-1-git-send-email-wency@cn.fujitsu.com> <1350629202-9664-4-git-send-email-wency@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 19 Oct 2012 03:01:12 -0400
Message-ID: <CAHGf_=oAH+Ky9JbrMrEsd53=a1NBq1+jtr1HkBwnGm4qBZCRAw@mail.gmail.com>
Subject: Re: [PATCH v3 3/9] memory-hotplug: flush the work for the node when
 the node is offlined
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wency@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com

On Fri, Oct 19, 2012 at 2:46 AM,  <wency@cn.fujitsu.com> wrote:
> From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
> If the node is onlined after it is offlined, we will clear the memory
> to store the node's information. This structure contains struct work,
> so we should flush work before the work's information is cleared.

This explanation is incorrect. Even if you don't call memset(), you should
call flush_work() at offline event. Because of, after offlinining, we
shouldn't touch any node data. Alive workqueue violate this principle.

And, hmmm... Wait. Usually workqueue shutdowning has two phase. 1)
inhibit enqueue new work 2) flush work. Otherwise other cpus may
enqueue new work after flush_work(). Where is (1)?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
