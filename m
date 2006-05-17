Date: Wed, 17 May 2006 12:22:34 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] Register sysfs file for hotpluged new node
In-Reply-To: <1147791312.6623.95.camel@localhost.localdomain>
References: <20060516210608.A3E5.Y-GOTO@jp.fujitsu.com> <1147791312.6623.95.camel@localhost.localdomain>
Message-Id: <20060517101339.21AA.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 2006-05-16 at 21:23 +0900, Yasunori Goto wrote:
> > +int arch_register_node(int num){
> > +       int p_node;
> > +       struct node *parent = NULL;
> > +
> > +       if (!node_online(num))
> > +               return 0;
> > +       p_node = parent_node(num);
> > +
> > +       if (p_node != num)
> > +               parent = &node_devices[p_node].node;
> > +
> > +       return register_node(&node_devices[num].node, num, parent);
> > +}
> > +
> > +void arch_unregister_node(int num)
> > +{
> > +       unregister_node(&node_devices[num].node);
> > +}
> ...
> > +int arch_register_node(int i)
> > +{
> > +       int error = 0;
> > +
> > +       if (node_online(i)){
> > +               int p_node = parent_node(i);
> > +               struct node *parent = NULL;
> > +
> > +               if (p_node != i)
> > +                       parent = &node_devices[p_node];
> > +               error = register_node(&node_devices[i], i, parent);
> > +       }
> > +
> > +       return error;
> > +} 
> 
> While you're at it, can you consolidate these two functions?  I don't
> see too much of a reason for keeping them separate.  You can probably
> also kill the 'struct i386_node' since it is just a 'struct node'
> wrapper anyway.  

Hmmmmmmmm.
I've worried that it can or can't be done. These codes look like midway of
registering hierarchies, because all of arch's parent_node() is just
parent_node(nid) = nid. I guess someone would like to make real code at
here. But, these might be just wrecks too. :-(

Ok. I'll try consolidate once. If there is a person who would like to
make something at here, he will complain. :-P

> I promise not to complain if you fix the i386 function's braces, too. ;)

Oops. Indeed.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
