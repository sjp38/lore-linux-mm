Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id F3DB16B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 19:08:25 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so6806560pbc.24
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 16:08:25 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id ez5si9826559pab.106.2013.11.25.16.08.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 16:08:24 -0800 (PST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 82A563EE1DA
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 09:08:22 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DDBA45DE52
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 09:08:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.nic.fujitsu.com [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4ABBF45DE4D
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 09:08:22 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3C8FF1DB803E
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 09:08:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E56721DB8038
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 09:08:21 +0900 (JST)
Message-ID: <5293E66F.8090000@jp.fujitsu.com>
Date: Mon, 25 Nov 2013 19:08:15 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch -mm] mm, mempolicy: silence gcc warning
References: <alpine.DEB.2.02.1311121811310.29891@chino.kir.corp.google.com>	<20131120141534.06ea091ca53b1dec60ace63d@linux-foundation.org>	<CAHGf_=ooNHx=2HeUDGxrZFma-6YRvL42ViDMkSOqLOffk8MVsw@mail.gmail.com> <20131125123108.79c80eb59c2b1bc41c879d9e@linux-foundation.org>
In-Reply-To: <20131125123108.79c80eb59c2b1bc41c879d9e@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kosaki.motohiro@jp.fujitsu.com, rientjes@google.com, fengguang.wu@intel.com, keescook@chromium.org, riel@redhat.com, linux-mm@kvack.org

(11/25/2013 3:31 PM), Andrew Morton wrote:
> On Sat, 23 Nov 2013 15:49:08 -0500 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
>>>> --- a/mm/mempolicy.c
>>>> +++ b/mm/mempolicy.c
>>>> @@ -2950,7 +2950,7 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
>>>>               return;
>>>>       }
>>>>
>>>> -     p += snprintf(p, maxlen, policy_modes[mode]);
>>>> +     p += snprintf(p, maxlen, "%s", policy_modes[mode]);
>>>>
>>>>       if (flags & MPOL_MODE_FLAGS) {
>>>>               p += snprintf(p, buffer + maxlen - p, "=");
>>>
>>> mutter.  There are no '%'s in policy_modes[].  Maybe we should only do
>>> this #ifdef CONFIG_KEES.
>>>
>>> mpol_to_str() would be simpler (and slower) if it was switched to use
>>> strncat().
>>
>> IMHO, you should queue this patch. mpol_to_str() is not fast path at all and
>> I don't want worry about false positive warning.
> 
> Yup, it's in mainline.

Thanks.

> 
>>> It worries me that the CONFIG_NUMA=n version of mpol_to_str() doesn't
>>> stick a '\0' into *buffer.  Hopefully it never gets called...
>>
>> Don't worry. It never happens. Currently, all of caller depend on CONFIG_NUMA.
>> However it would be nice if CONFIG_NUMA=n version of mpol_to_str() is
>> implemented
>> more carefully. I don't know who's mistake.
> 
> Put a BUG() in there?

I think this is enough. What do you think?


commit 5691f7f336c511d39fc05821d204a8f7ba18c0cf
Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date:   Mon Nov 25 18:38:25 2013 -0500

    mempolicy: implement mpol_to_str() fallback implementation when !CONFIG_NUMA

    Andrew Morton pointed out mpol_to_str() has no fallback implementation
    for !CONFIG_NUMA and it could be dangerous because callers might assume
    buffer is filled zero terminated string. Fortunately there is no such
    caller. But it would be nice to provide default safe implementation.

    Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 9fe426b..eee0597 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -309,6 +309,8 @@ static inline int mpol_parse_str(char *str, struct mempolicy **mpol)

 static inline void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 {
+	strncpy(buffer, "default", maxlen-1);
+	buffer[maxlen-1] = '\0';
 }

 static inline int mpol_misplaced(struct page *page, struct vm_area_struct *vma,




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
