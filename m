Date: Sun, 1 Oct 2006 23:18:11 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] another way to speed up fake numa node page_alloc
Message-Id: <20061001231811.26f91c47.pj@sgi.com>
In-Reply-To: <20060925091452.14277.9236.sendpatchset@v0>
References: <20060925091452.14277.9236.sendpatchset@v0>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, rientjes@google.com, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

pj wrote:
+struct zonelist_faster {
+	nodemask_t fullnodes;		/* nodes recently lacking free memory */
+	unsigned long last_full_zap;	/* jiffies when fullnodes last zero'd */
+	unsigned short node_id[MAX_NUMNODES * MAX_NR_ZONES]; /* zone -> nid */
+};

This seems broken on systems with more than one zone per node.

If whichever zone comes first of the several zones on a node (the
several consecutive zones in the zonelist that evaluate to the same
node) ever gets full, then the other zones on that node will be
skipped over, because they would end up on a full node.  Once per
second, we will retry the first zone from that node, but if it is still
full, we would -still- skip over the remaining zones without looking at
them.  That is, these other zones wouldn't even get the courtesy of a
once per second consideration.

Only if every allowed node in the system is full will we actually
rescan the zonelist with this faster mechanism disabled and seriously
examine these other zones on such a node.

Perhaps instead of a single 'nodemask_t fullnodes', I need a small
array of these nodemasks, one per MAX_NR_ZONES.  Then I could select
which fullnodes nodemask to check by taking my index into the node_id[]
array, modulo MAX_NR_ZONES.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
