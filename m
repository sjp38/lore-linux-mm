Date: Tue, 3 Jun 2008 17:44:14 -0500
From: Cliff Wickman <cpw@sgi.com>
Subject: Re: [PATCH 1/1] SGI UV: TLB shootdown using broadcast assist unit
Message-ID: <20080603224414.GA19382@sgi.com>
References: <E1K3AWE-00056Z-83@eag09.americas.sgi.com> <20080602150122.GB6835@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080602150122.GB6835@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

Ingo,

I've addressed all the issues that you raised, and I think made
some good structural improvements as a result.

Also, in moving my atomic asm's to atomic_64.h and testing them
further I uncovered problems that I then addressed.
I'm no guru on x86 asm's however, so an inspection of those is
probably a good idea.

I'll re-submit the patch itself momentarily.

> Date: Mon, 2 Jun 2008 17:01:22 +0200
> From: Ingo Molnar <mingo@elte.hu>
> To: Cliff Wickman <cpw@sgi.com>
> Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
> 	the arch/x86 maintainers <x86@kernel.org>
> 
> Subject: Re: [PATCH 1/1] SGI UV: TLB shootdown using broadcast assist unit
> 
> * Cliff Wickman <cpw@sgi.com> wrote:
> 
> > From: Cliff Wickman <cpw@sgi.com>
> > 
> > TLB shootdown for SGI UV.
> 
> looks mostly good to me, but there are a few code structure and 
> stylistic nits:
> 
> > +	if (is_uv_system() && uv_flush_tlb_others(&cpumask, mm, va))
> > +			return;
> 
> one tab too many.

done
 
> > +struct bau_control **uv_bau_table_bases;
> > +static int uv_bau_retry_limit;
> > +static int uv_nshift;		/* position of pnode (which is nasid>>1) */
> > +static unsigned long uv_mmask;
> 
> shouldnt these be __read_mostly ?

done (never considered;  but does seem logical for all 4 of these)
 
> > +{
> > +	int fw;
> > +
> > +	fw = (1 << (resource + UV_SW_ACK_NPENDING)) | (1 << resource);
> > +	msg->replied_to = 1;
> > +	msg->sw_ack_vector = 0;
> > +	if (msp)
> > +		msp->seen_by.bits = 0;
> > +	uv_write_local_mmr(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS, fw);
> 
> 'fw' is int here, while uv_write_local_mmr() takes 'unsigned long', so 
> 'fw' will be sign-extended. It's better to use the natural type of such 
> values, even if you only fill in low bits. (otherwise it can later on 
> result in unexpected results if the u32 value here has bit 31 set.)

done
 
> > +		local_flush_tlb();
> > +		__get_cpu_var(ptcstats).alltlb++;
> > +	} else {
> > +		__flush_tlb_one(msg->address);
> > +		__get_cpu_var(ptcstats).onetlb++;
> > +	}
> > +
> > +	__get_cpu_var(ptcstats).requestee++;
> > +
> > +	atomic_inc_short(&msg->acknowledge_count);
> > +	if (msg->number_of_cpus == msg->acknowledge_count)
> > +		uv_reply_to_message(sw_ack_slot, msg, msp);
> > +	return;
> > +}
> > +
> > +/*
> > + * Examine the payload queue on all the distribution nodes to see
> > + * which messages have not been seen, and which cpu(s) have not seen them.
> > + *
> > + * Returns the number of cpu's that have not responded.
> > + */
> > +static int
> > +uv_examine_destinations(struct bau_target_nodemask *distribution)
> > +{
> > +	int sender;
> > +	int i;
> > +	int j;
> > +	int k;
> > +	int count = 0;
> > +	struct bau_control *bau_tablesp;
> > +	struct bau_payload_queue_entry *msg;
> > +	struct bau_msg_status *msp;
> > +
> > +	sender = smp_processor_id();
> > +	for (i = 0; i < (sizeof(struct bau_target_nodemask) * BITSPERBYTE);
> > +	     i++) {
> > +		if (bau_node_isset(i, distribution)) {
> 
> use a:
> 
> 		if (!(...))
> 			continue;
> 
> construct to make the function more readable and to save an indentation 
> level. Possibly split the iterator body into a separate function as 
> well.

done (the former; reduced indentation one level)

> > +}
> > +
> > +/**
> > + * uv_flush_tlb_others - globally purge translation cache of a virtual
> > + * address or all TLB's
> > + * @cpumaskp: mask of all cpu's in which the address is to be removed
> > + * @mm: mm_struct containing virtual address range
> > + * @va: virtual address to be removed (or TLB_FLUSH_ALL for all TLB's on cpu)
> > + *
> > + * This is the entry point for initiating any UV global TLB shootdown.
> > + *
> > + * Purges the translation caches of all specified processors of the given
> > + * virtual address, or purges all TLB's on specified processors.
> > + *
> > + * The caller has derived the cpumaskp from the mm_struct and has subtracted
> > + * the local cpu from the mask.  This function is called only if there
> > + * are bits set in the mask. (e.g. flush_tlb_page())
> > + *
> > + * The cpumaskp is converted into a nodemask of the nodes containing
> > + * the cpus.
> > + */
> > +int
> > +uv_flush_tlb_others(cpumask_t *cpumaskp, struct mm_struct *mm, unsigned long va)
> > +{
> > +	int i;
> > +	int blade;
> > +	int cpu;
> > +	int bit;
> > +	int right_shift;
> > +	int this_blade;
> > +	int exams = 0;
> > +	int tries = 0;
> > +	long source_timeouts = 0;
> > +	long destination_timeouts = 0;
> > +	unsigned long index;
> > +	unsigned long mmr_offset;
> > +	unsigned long descriptor_status;
> > +	struct bau_activation_descriptor *bau_desc;
> > +	ktime_t time1, time2;
> 
> this function needs to be broken up into smaller ones.

done -- now 3 functions
 
> > +	bau_desc += (UV_ITEMS_PER_DESCRIPTOR * cpu);
> 
> unnecessary paranthesis.

done
  
> > +		/* leave the bits for the remote cpu's in the mask until
> > +		   success; on failure we fall back to the IPI method */
> 
> use such comment style:
> 
>  /*
>   * Comment
>   */
> (this applies to many other places in this file as well)

done
  
> > +	time1 = ktime_get();
> 
> dont use ktime_get() in performance-sensitive code, it can get _really_ 
> expensive if GTOD falls back to pmtimer or hpet or other southbridge-ish 
> time methods.

done. using get_cycles
 
> > +static const struct file_operations proc_uv_ptc_operations = {
> > +	.open = uv_ptc_proc_open,
> > +	.read = seq_read,
> > +	.write = uv_ptc_proc_write,
> > +	.llseek = seq_lseek,
> > +	.release = seq_release,
> > +};
> 
> do something like this for structure initialization:
> 
> > +static const struct file_operations proc_uv_ptc_operations = {
> > +	.open		= uv_ptc_proc_open,
> > +	.read		= seq_read,
> > +	.write		= uv_ptc_proc_write,
> > +	.llseek		= seq_lseek,
> > +	.release	= seq_release,
> > +};
> 
> to make it easier to read.

done

> > +static struct proc_dir_entry *proc_uv_ptc;
> 
> static variable in the middle of file - data should move up to the 
> header portion of the file, or this functionality should go into a 
> separate file if it's well-isolated.

done

> > +static int __init
> > +uv_ptc_init(void)
> 
> unnecessary line break. (applies to many other function definitions in 
> this file too)

done (this was a style choice -- but changed throughout)
 
> > +{
> > +	static struct proc_dir_entry *sgi_proc_dir;
> 
> static variable hidden in function. It should move into head of the file 
> instead.

done. removed
 
> > +uv_ptc_exit(void)
> > +{
> > +	remove_proc_entry(UV_PTC_BASENAME, NULL);
> > +}
> > +
> > +module_init(uv_ptc_init);
> > +module_exit(uv_ptc_exit);
> 
> why is this modular?

no good reason.  was inherited from some sn2 code
done
 
> > +/*
> > + * Initialization of BAU-related structures
> > + */
> > +int __init
> > +uv_bau_init(void)
> > +{
> > +	int i;
> > +	int j;
> > +	int blade;
> > +	int nblades;
> > +	int *ip;
> > +	int pnode;
> > +	int last_blade;
> > +	int cur_cpu = 0;
> > +	unsigned long pa;
> > +	unsigned long n;
> > +	unsigned long m;
> > +	unsigned long mmr_image;
> > +	unsigned long apicid;
> > +	char *cp;
> > +	struct bau_control *bau_tablesp;
> > +	struct bau_activation_descriptor *adp, *ad2;
> > +	struct bau_payload_queue_entry *pqp;
> > +	struct bau_msg_status *msp;
> > +	struct bau_control *bcp;
> 
> function way too large - per node initialization should go into a helper 
> function to reduce function linecount and complexity.

done
  became 6 functions of 20-40 lines each
 
> > +}
> > +
> > +__initcall(uv_bau_init);
> 
> unnecessary newline in front of __initcall().

done
 
> > +
> > +#define UV_ITEMS_PER_DESCRIPTOR 8
> > +#define UV_CPUS_PER_ACT_STATUS 32
> > +#define UV_ACT_STATUS_MASK 0x3
> > +#define UV_ACT_STATUS_SIZE 2
> > +#define UV_ACTIVATION_DESCRIPTOR_SIZE 32
> > +#define UV_DISTRIBUTION_SIZE 256
> > +#define UV_SW_ACK_NPENDING 8
> > +#define UV_BAU_MESSAGE 200	/* Messaging irq; see irq_64.h */
> > +				/* and include/asm-x86/hw_irq_64.h */
> > +				/* To be dynamically allocated in the future */
> > +#define UV_NET_ENDPOINT_INTD 0x38
> > +#define UV_DESC_BASE_PNODE_SHIFT 49 /* position of pnode (nasid>>1) in MMR */
> > +#define UV_PAYLOADQ_PNODE_SHIFT 49
> 
> please use the style and alignment found in other areas of 
> include/asm-x86, such as include/asm-x86/processor.h. (applies to other 
> areas of this patch as well)

done (I think)
 
> > +/*
> > + * atomic increment of a short integer
> > + * (rather than using the __sync_add_and_fetch() intrinsic)
> > + *
> > + * returns the new value of the variable
> > + */
> > +static inline short int atomic_inc_short(short int *v)
> > +{
> > +	asm volatile("movw $1, %%cx\n"
> > +			"lock ; xaddw %%cx, %0\n"
> > +			: "+m" (*v)		/* outputs */
> > +			: : "%cx", "memory");	/* inputs : clobbereds */
> > +	return *v;
> > +}
> 
> this (and the other atomic_*() additions) should go into atomic.h 
> instead.

done (into atomic_64.h)
 
> > +int uv_flush_tlb_others(cpumask_t *, struct mm_struct *, unsigned long);
> > +void uv_bau_message_intr1(void);
> > +void uv_bau_timeout_intr1(void);
> 
> function prototypes in headers should use 'extern'.

done
 
-Cliff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
