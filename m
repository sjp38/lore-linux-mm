Date: Fri, 17 Feb 2006 12:33:17 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback list initialization
In-Reply-To: <200602170223.34031.ak@suse.de>
References: <200602170223.34031.ak@suse.de>
Message-Id: <20060217115427.4060.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: torvalds@osdl.org, akpm@osdl.org, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> -		n = (node+i) % num_online_nodes();
> +		n = (node+i) % (highest_node + 1);


To tell the truth, I think that both of their calculations
are conceptually strange.
The first and true issue is that variable name is wrong.
Ok, I'll rewrite true meaning of this calculation

True vaiable names are here.
i -> online_node_id.
node -> start_node_id.
n -> target_node_id.

So, this loop is like followings.

  for_each_online_node(online_node_id){
     target_node_id = (start_node_id + online_node_id)
                         %  num_online_nodes()
                :
  }
  
What does mean (start_node_id + ONLINE_node_id)?
                             ~~~

This means nothing even if using highest_node_id.
If one of node is removed, or offlined at first,
trouble will be occur. target_node_id may point offlined node.

  ex) start_node_id = 1, online nodes are 0, 1, 3....
       (start_node_id + online_node_id) % num_online_nodes
              1                1              3
       target_node_id will be 2! It is offlined node.


But, now, node id is contiguous, and there is/(was?) no trouble.
So, everyone haven't minded this....

Bye.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
