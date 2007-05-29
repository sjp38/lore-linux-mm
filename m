Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id l4T7TYDS010627
	for <linux-mm@kvack.org>; Tue, 29 May 2007 00:29:37 -0700
Received: from ug-out-1314.google.com (ugb70.prod.google.com [10.66.2.70])
	by zps77.corp.google.com with ESMTP id l4T7TWAm004142
	for <linux-mm@kvack.org>; Tue, 29 May 2007 00:29:33 -0700
Received: by ug-out-1314.google.com with SMTP id 70so826282ugb
        for <linux-mm@kvack.org>; Tue, 29 May 2007 00:29:32 -0700 (PDT)
Message-ID: <6599ad830705290029w18f8fdbbmac312c362bfccb67@mail.gmail.com>
Date: Tue, 29 May 2007 00:29:32 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 1/1] hotplug cpu: move tasks in empty cpusets to parent
In-Reply-To: <20070522205300.6C18D371895@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070522205300.6C18D371895@attica.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/22/07, Cliff Wickman <cpw@sgi.com> wrote:
> - * Call with both manage_mutex and callback_mutex held.
> + * Call with both manage_sem and callback_sem held so
> + * that this function can modify cpus_allowed and mems_allowed.
>   *
> - * Recursive, on depth of cpuset subtree.
> + * This walk processes the tree from top to bottom, completing one layer
> + * before dropping down to the next.  It always processes a node before
> + * any of its children.
>   */
> +static void remove_tasks_from_empty_cpusets(const struct cpuset *root, int *count)
> +{
> +       struct cpuset *cp;      /* scans cpusets being updated */
> +       struct cpuset *child;   /* scans child cpusets of cp */
> +       struct kfifo *queue;    /* fifo queue of cpusets to be updated */
> +
> +       queue = kfifo_alloc(number_of_cpusets * sizeof(cp), GFP_KERNEL, NULL);
> +       if (queue == ERR_PTR(-ENOMEM))
> +               return;

You can't call memory allocation functions while holding
callback_mutex - otherwise you can theoretically deadlock if
_alloc_pages() calls cpuset_zone_allowed_*()

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
