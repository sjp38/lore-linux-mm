Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5NHvsBY014025
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 13:57:54 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5NHvScq292266
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 11:57:28 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5NHvs3h007759
	for <linux-mm@kvack.org>; Fri, 23 Jun 2006 11:57:54 -0600
Subject: Re: [Lhms-devel] [RFC] patch [1/1] x86_64 numa aware sparsemem
	add_memory	functinality
From: keith mannthey <kmannth@us.ibm.com>
Reply-To: kmannth@us.ibm.com
In-Reply-To: <1151082833.10877.13.camel@localhost.localdomain>
References: <1150868581.8518.28.camel@keithlap>
	 <1151082833.10877.13.camel@localhost.localdomain>
Content-Type: text/plain
Date: Fri, 23 Jun 2006 10:57:52 -0700
Message-Id: <1151085472.6285.4.camel@keithlap>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dave hansen <haveblue@us.ibm.com>
Cc: Prarit Bhargava--redhat <prarit@redhat.com>, linux-mm <linux-mm@kvack.org>, ak@suse.de, konrad <darnok@us.ibm.com>, lhms-devel <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-06-23 at 10:13 -0700, Dave Hansen wrote: 
> >  int add_memory(u64 start, u64 size)
> >  {
> > -       struct pglist_data *pgdat = NODE_DATA(0);
> > +       struct pglist_data *pgdat = NODE_DATA(new_memory_to_node(start,start+size));
> >         struct zone *zone = pgdat->node_zones + MAX_NR_ZONES-2;
> 
> How about just having new_memory_to_node() take the range and return the
> pgdat?  Should make that line a bit shorter.

In the -mm tree things are a little different.  The acpi layer (and
something for ppc) is passing the nid down the a generic add memory
call.  

  This int add_memory(u64 start, u64 size) is going away with something
more like int add_memory(int nid, u64 start, u64 size) this changes
things some. 

  I have patches against the -mm stack but I had a little trouble with
my testbox's file-system last night so I should have them out this
afternoon.  

> > -#ifndef RESERVE_HOTADD 
> > +#if !defined(RESERVE_HOTADD) && !defined(CONFIG_MEMORY_HOTPLUG)
> >  #define hotadd_percent 0       /* Ignore all settings */
> >  #endif
> >  static u8 pxm2node[256] = { [0 ... 255] = 0xff };
> > @@ -219,9 +219,9 @@
> >         allocated += mem;
> >         return 1;
> >  }
> > -
> > +#endif
> >  /*
> 
> Could this use another Kconfig option which gives a name to this
> condition?

  This is sort of a redundant force off.  I am not sure if there is a
code path to the SRAT code without  RESERVE_HOTADD or
CONFIG_MEMORY_HOTPLUG defined.  

  hotadd_percent can only change from 0 with an explicit command-line
numa=hotadd=XXX boot so maybe taking this  
#define hotadd_percent 0
out all together might be the better way to go if the code patch is
going to be shared. 

> 
> > +#ifdef RESERVE_HOTADD
> >         if (!hotadd_enough_memory(&nodes_add[node]))  {
> >                 printk(KERN_ERR "SRAT: Hotplug area too large\n");
> >                 return -1;
> >         }
> > -
> > +#endif 
> 
> This #ifdef is probably better handled by an #ifdef in the header for
> hotadd_enough_memory().

  hotadd_enough_memory is static there is no header entry for it. 

Thanks for the feedback,
  Keith 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
