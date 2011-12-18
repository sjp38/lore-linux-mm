Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 5D4A56B004D
	for <linux-mm@kvack.org>; Sun, 18 Dec 2011 16:28:43 -0500 (EST)
Received: by qadc16 with SMTP id c16so3411995qad.14
        for <linux-mm@kvack.org>; Sun, 18 Dec 2011 13:28:42 -0800 (PST)
Message-ID: <4EEE5B08.8010703@gmail.com>
Date: Sun, 18 Dec 2011 16:28:40 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RESEND] mm: Fix off-by-one bug in print_nodes_state
References: <1324209529-15892-1-git-send-email-ozaki.ryota@gmail.com>
In-Reply-To: <1324209529-15892-1-git-send-email-ozaki.ryota@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ryota Ozaki <ozaki.ryota@gmail.com>
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>, linux-mm@kvack.org, stable@kernel.org

(12/18/11 6:58 AM), Ryota Ozaki wrote:
> /sys/devices/system/node/{online,possible} involve a garbage byte
> because print_nodes_state returns content size + 1. To fix the bug,
> the patch changes the use of cpuset_sprintf_cpulist to follow the
> use at other places, which is clearer and safer.
> 
> This bug was introduced since v2.6.24.
> 
> Signed-off-by: Ryota Ozaki<ozaki.ryota@gmail.com>
> ---
>   drivers/base/node.c |    8 +++-----
>   1 files changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 5693ece..ef7c1f9 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -587,11 +587,9 @@ static ssize_t print_nodes_state(enum node_states state, char *buf)
>   {
>   	int n;
> 
> -	n = nodelist_scnprintf(buf, PAGE_SIZE, node_states[state]);
> -	if (n>  0&&  PAGE_SIZE>  n + 1) {
> -		*(buf + n++) = '\n';
> -		*(buf + n++) = '\0';
> -	}
> +	n = nodelist_scnprintf(buf, PAGE_SIZE-2, node_states[state]);

PAGE_SIZE-1. This seems another off by one. buf[n++] = '(J\n' mean
override old trailing '\0' and buf[n] = '\0' mean to append one byte.
Then totally, we append one byte.

> +	buf[n++] = '(B\n';
> +	buf[n] = '\0';
>   	return n;
>   }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
