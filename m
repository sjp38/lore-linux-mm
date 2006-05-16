Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k4GF7bP5029338
	for <linux-mm@kvack.org>; Tue, 16 May 2006 11:07:37 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4GF7YV1183460
	for <linux-mm@kvack.org>; Tue, 16 May 2006 09:07:35 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k4GF6rIf002786
	for <linux-mm@kvack.org>; Tue, 16 May 2006 09:07:34 -0600
Subject: Re: [PATCH] Register sysfs file for hotpluged new node
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060516210608.A3E5.Y-GOTO@jp.fujitsu.com>
References: <20060516210608.A3E5.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 16 May 2006 07:55:12 -0700
Message-Id: <1147791312.6623.95.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-05-16 at 21:23 +0900, Yasunori Goto wrote:
> +int arch_register_node(int num){
> +       int p_node;
> +       struct node *parent = NULL;
> +
> +       if (!node_online(num))
> +               return 0;
> +       p_node = parent_node(num);
> +
> +       if (p_node != num)
> +               parent = &node_devices[p_node].node;
> +
> +       return register_node(&node_devices[num].node, num, parent);
> +}
> +
> +void arch_unregister_node(int num)
> +{
> +       unregister_node(&node_devices[num].node);
> +}
...
> +int arch_register_node(int i)
> +{
> +       int error = 0;
> +
> +       if (node_online(i)){
> +               int p_node = parent_node(i);
> +               struct node *parent = NULL;
> +
> +               if (p_node != i)
> +                       parent = &node_devices[p_node];
> +               error = register_node(&node_devices[i], i, parent);
> +       }
> +
> +       return error;
> +} 

While you're at it, can you consolidate these two functions?  I don't
see too much of a reason for keeping them separate.  You can probably
also kill the 'struct i386_node' since it is just a 'struct node'
wrapper anyway.  

I promise not to complain if you fix the i386 function's braces, too. ;)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
