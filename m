Received: by an-out-0708.google.com with SMTP id d30so235049and
        for <linux-mm@kvack.org>; Tue, 06 Nov 2007 02:36:25 -0800 (PST)
Message-ID: <cfd9edbf0711060236l73549554wb340e08e8b671eac@mail.gmail.com>
Date: Tue, 6 Nov 2007 11:36:24 +0100
From: "=?ISO-8859-1?Q?Daniel_Sp=E5ng?=" <daniel.spang@gmail.com>
Subject: Re: [RFC Patch] Thrashing notification
In-Reply-To: <20071105183025.GA4984@dmt>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <op.t1bp13jkk4ild9@bingo> <20071105183025.GA4984@dmt>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@kvack.org>
Cc: linux-mm@kvack.org, drepper@redhat.com, riel@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, balbir@linux.vnet.ibm.com, 7eggert@gmx.de
List-ID: <linux-mm.kvack.org>

On 11/5/07, Marcelo Tosatti <marcelo@kvack.org> wrote:
> Hooking into try_to_free_pages() makes the scheme suspectible to
> specifics such as:
>
> - can the task writeout pages?
> - is the allocation a higher order one?
> - in what zones is it operating on?
>
> Remember that notifications are sent to applications which can allocate
> globally... It is not very useful to send notifications for a userspace
> which has a large percentage of its memory in highmem if the system is
> having a lowmem zone shortage (granted that the notify-on-swap heuristic
> has that problem, but you can then argue that swap affects system
> performance globally, and it generally does in desktop systems).

On a swapless system, the alternative is often to get killed by the oom killer.

> Other than that tuning "priority" from try_to_free_pages() is rather
> difficult for users/admins.

Yes, that parameter might need some tuning, but my initial tests show
that is pretty robust if you keep out of the ends of the interval.

> My previous patches had the zone limitation, but the following way of
> asking "are we low on memory?" gets rid of it:
>
> +static unsigned int mem_notify_poll(struct file *file, poll_table *wait)
> +{
> +       unsigned int val = 0;
> +       struct zone *zone;
> +       int tpages_low, tpages_free, tpages_reserve;
> +
> +       tpages_low = tpages_free = tpages_reserve = 0;
> +
> +       poll_wait(file, &mem_wait, wait);
> +
> +       for_each_zone(zone) {
> +               if (!populated_zone(zone))
> +                       continue;
> +               tpages_low += zone->pages_low;
> +               tpages_free += zone_page_state(zone, NR_FREE_PAGES);
> +               /* always use the reserve of the highest allocation type */
> +               tpages_reserve += zone->lowmem_reserve[MAX_NR_ZONES-1];
> +       }
> +
> +       if (mem_notify_status || (tpages_free <= tpages_low + tpages_reserve))
> +               val = POLLIN;
> +
> +       return val;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
