Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 6BEFD6B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 17:48:35 -0500 (EST)
Received: by qcsd17 with SMTP id d17so3430373qcs.14
        for <linux-mm@kvack.org>; Sun, 18 Dec 2011 14:48:34 -0800 (PST)
Message-ID: <4EEE6DC0.2030007@gmail.com>
Date: Sun, 18 Dec 2011 17:48:32 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RESEND] mm: Fix off-by-one bug in print_nodes_state
References: <1324209529-15892-1-git-send-email-ozaki.ryota@gmail.com> <alpine.DEB.2.00.1112181439500.1364@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1112181439500.1364@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ryota Ozaki <ozaki.ryota@gmail.com>, linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, linux-mm@kvack.org, stable@kernel.org

(12/18/11 5:44 PM), David Rientjes wrote:
> On Sun, 18 Dec 2011, Ryota Ozaki wrote:
>
>> /sys/devices/system/node/{online,possible} involve a garbage byte
>> because print_nodes_state returns content size + 1. To fix the bug,
>> the patch changes the use of cpuset_sprintf_cpulist to follow the
>> use at other places, which is clearer and safer.
>>
>
> It's not a garbage byte, sysdev files use a buffer created with
> get_zeroed_page(), so extra byte is guaranteed to be zero since
> nodelist_scnprintf() won't write to it.  So the issue here is that
> print_nodes_state() returns a size that is off by one according to
> ISO C99 although it won't cause a problem in practice.
>
>> This bug was introduced since v2.6.24.
>>
>
> It's not a bug, the result of a 4-node system would be "0-3\n\0" and
> returns 5 correctly.  You can verify this very simply with strace.

Usually, /sys files don't output trailing 'JPY0'. And, 'JPY0' is not regular
io friendly. So I can imagine some careless programmer think it is 
garbage. Is there any benefit to show trailing 'JPY0'?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
