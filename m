Message-ID: <450AA5AA.3030202@shadowen.org>
Date: Fri, 15 Sep 2006 14:07:54 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: [PATCH] Get rid of zone_table
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com> <45092FE6.3060706@shadowen.org> <Pine.LNX.4.64.0609141431560.5688@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609141431560.5688@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 14 Sep 2006, Andy Whitcroft wrote:
> 
>> Proposed implementation:
>>
>>     | Node | Zone | [Section] | xxxxx |      Flags       |
>>      \____/ \____/
>>         |      |__________________
>>   .- - -|- - - - - - - -.         |
> 
> Right. There is one lookup here in the node_data array. The combination
> with the zone is an address calculation and does not require a lookup.
> 

Yes, you are correct, the zones are in the node, so my diagram is
missleading it should be:

    | Node | Zone | [Section] | xxxxx |      Flags       |
     \____/ \____/
        |      |__________________
  .- - -|- - - - - - - -.         |
  .     v               .         |
  . +-----------+       .         |
  . | node_data |--&node----------+----> &zone
  . +-----------+       .         ^
  .     ^               .         |
   - - -|- - - - - - - -A         |
        |                         |
    +---------------+             |
    | section_table |             |
    +---------------+             |
        ^                         |
        |                         |
      __|_____________________   _|__
     /                        \ /    \
    |         Section          | Zone |      Flags       |

Now as you say (in the non-SPARSMEM case) this is equivalent to the
zone_table lookup, but has the advantage of the node_data already likely
to be hot.  If we can say that node_data is sufficiently hot, then the
shrink in the size of the section_table and that together should help
amortise the additional lookup.

I think we do need to benchmark this comparitivly to see.

I've also tried to respond to you comments below, but the key message
here is that this is an interesting change that we need to perf. test to
see its impact.  If its not measureable then it seems reasonable.

>>   .     v               .         v
>>   . +-----------+       .  +-----------+
>>   . | node_data |--&node-->| NODE_DATA |----> &zone
>>   . +-----------+       .  +-----------+
>>   .     ^               .         ^
>>    - - -|- - - - - - - -A         |
>>         |                         |
>>     +---------------+             |
>>     | section_table |             |
>>     +---------------+             |
> 
> Right here is the second lookup for the case in which the section does not 
> fit.
> 
>>         ^                         |
>>         |                         |
>>       __|_____________________   _|__
>>      /                        \ /    \
>>     |         Section          | Zone |      Flags       |
>>
>>
>> Christoph Lameter wrote:
>>> The zone table is mostly not needed. If we have a node in the page flags 
>>> then we can get to the zone via NODE_DATA(). In case of SMP and UP 
>>> NODE_DATA() is a constant pointer which allows us to access an exact 
>>> replica of zonetable in the node_zones field. In all of the above cases 
>>> there will be no need at all for the zone table.
>> Ok here we are talking about the segment of the second diagram ringed
>> and marked A.  Yes the compiler/we should be able to optimise this case
>> to directly use the zonelist.  However, this is also true of the current
>> scheme and would be a fairly trivial change in that framework.
> 
> What would the compiler optimize? You mean the zonelist in the node 
> structure or the zonetable?
> 

I am saying that when you express the zone lookup in terms of the
NODE_DATA(nid) in the non-NUMA case the compiler/optimiser has
sufficient information to make collapse the whole thing into a constant.

>> Something like the below.
>>
>> @@ -477,7 +477,10 @@ static inline int page_zone_id(struct pa
>>  }
>>  static inline struct zone *page_zone(struct page *page)
>>  {
>> -       return zone_table[page_zone_id(page)];
>> +       if (NODE_SHIFT)
>> +               return zone_table[page_zone_id(page)];
>> +       else
>> +               return NODE_DATA(0)->node_zones[page_zonenum(page)];
>>  }
> 
> Yes that code was proposed in the RFC. See linux-mm. Dave suggested that 
> we can eliminate the zone_table or the section_to_node_table completely
> because we can actually fit the node into the page flags with some 
> adjustments to sparsemem.

This patch fragment, implements the optimisation in your code (I've
boxed  A) for the non-NUMA case, but does it within the old code
framework.  ie just this change should be enough to get all the benfits
you indicate for UP and SMP.  I am wondering if all the other change is
needed to get the benefit.

>> A similar thing could be done for page_to_nid which should always be zero.
> 
> page_to_nid already uses page_zone in that case.
> 
>>> The section_to_node table (if we still need it) is still the size of the 
>>> number of sections but the individual elements are integers (which already 
>>> saves 50% on 64 bit platforms) and we do not need to duplicate the entries 
>>> per zone type. So even if we have to keep the table then we shrink it to 
>>> 1/4th (32bit) or 1/8th )(64bit).
>> Ok, this is based on half for moving from a pointer to an integer.  The
>> rest is based on the fact we have 4 zones.  Given most sane
>> architectures only have ZONE_DMA we should be able to get a large
>> percentage of this saving just from knowing the highest 'valid' zone per
>> architecture.
> 
> NUMAQ only populates HIGHMEM on nodes other than zero. You will get 
> no benefit with such a scheme.
> 

Yes, but NUMA-Q is not a sane architecture :).  I am talking about the
places we more care, like 64bit.  Though I tried to say later that I
don't think we ever hit this scenario for 64 bit systems.

>> Let us consider the likely sizes of the zone_table for a SPARSEMEM
>> configuration:
>>
>> 1) the 32bit case.  Here we have a limitation of a maximum of 6 bits
>> worth of sections (64 of them).  So the maximum zone_table size is 4 *
>> 64 * 4 == 1024, so 1KB of zone_table.
> 
> Can we fit the node in there for all possible 32 bit NUMA machines?

No its never fits in there when sparsmem is enabled on 32 bit, as we use
the same bits normally reserved for the node.  The zone_table is
actually the same size either way in the current code.

>> General comments.  Although this may seem of the same order of
>> complexity and therefore a performance drop in, there does seem to be a
>> significant number of additional indirections on a NUMA system.
> 
> Could you tell me wher the "indirections" come from? AFAIK there is only
> one additional indirection that is offset by the NODE_DATA array being
> cache hot. page_to_nid goes from 3 indirections to one with this scheme.

With the clarification to the zone lookup we are indeed at one
additional indirection.  They key decision when forming this layout was
that page_zone was used heavily on hot paths, page_to_nid was not used
very often at all.  So an optimisation there was not as valuable; this
may of course no longer be the case.

> 
>> I can see a very valid case for optimising the UP/SMP case where
>> NODE_DATA is a constant.  But that could be optimised as I indicate
>> above without a complete rewrite.
> 
> Could you have a look at the RFC wich does exactly that?

I did read the RFC, my point here was that you make two assertions, and
I was saying the first was clearly right and could be implemented
separately.  The second seemed to need validating.

1) that in the UP/SMP case we don't need the zone_table at all its just
dumb having it -- this seems very valid, but can be implemented in the
current framework as above with just those three lines of change.

2) that the zone_table is huge on 64 bit systems with lots of nodes --
which could be true, but I have yet to be convinced.  The key here is
that we need to force the NODE out of the flags for this code to strike
and I conjecture there isn't a 64 bit system that does it.  Now your
changes for this add an additional indirection to shrink the table, but
the table is pretty small in the use cases where I'd expect to see it
used (32 bit sparsemem).

>> Finally, if the change here was a valid one benchmark wise or whatever,
>> I think it would be nicer to push this in through the same interface we
>> currently have as that would allow other shaped zone_tables to be
>> brought back should a new memory layout come along.
> 
> It would be best to eliminate the zone_table or my section_to_node_table 
> completely. The section_to_node_table does not require maintanance 
> in the page allocator as the zone_table does.
> 
>>> Index: linux-2.6.18-rc6-mm2/include/linux/mm.h
>>> ===================================================================
> 
> I could not find any comments in here. Please cut down emails as much as 
> possible.

Soz.  Had conflicting requests on this one.  My preference is for shortness.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
