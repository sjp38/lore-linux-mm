Date: Thu, 08 May 2003 15:41:44 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Redundant zonelist initialization
Message-ID: <28740000.1052433703@[10.10.2.4]>
In-Reply-To: <20030508145218.GA4355@averell>
References: <20030508112339.GA7394@averell> <24990000.1052396565@[10.10.2.4]> <20030508145218.GA4355@averell>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

>> > When booting 2.5.69 on a 4 Node CONFIG_DISCONTIGMEM machine I get:
>> > 
>> > Building zonelist for node : 0
>> > Building zonelist for node : 1
>> > Building zonelist for node : 2
>> > Building zonelist for node : 3
>> > Building zonelist for node : 0
>> > Building zonelist for node : 0
>> > Building zonelist for node : 0
>> > Building zonelist for node : 0
>> > 
>> > Why does it initialize the zonelist for node 0 five times?
>> 
>> Looks like you have numnodes wrong ...
>> 
>> void __init build_all_zonelists(void)
>> {
>>         int i;
>> 
>>         for(i = 0 ; i < numnodes ; i++)
>>                 build_zonelists(NODE_DATA(i));
>> }
> 
> Only with new mathematics :-) How can any value for numnodes explain 
> such a sequence ? 

I was thinking of "numnodes = 8", and just screwed up data for the last
few. Not quite sure how you'd avoid derefing a NULL ptr though, I guess.
 
> I think it actually comes from the two loops calling build_zonelist_node 
> in build_zonelists(). 

I don't see how it can - that printk is before the loops.

static void __init build_zonelists(pg_data_t *pgdat)
{
        int i, j, k, node, local_node;

        local_node = pgdat->node_id;
        printk("Building zonelist for node : %d\n", local_node);

> But I'm not sure why it produces such a strange sequence.

Throw a few printks in there, should tell you easily enough. 
I'll bet you a couple of beers on it being numnodes ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
